<?php
namespace Grav\Plugin\Shortcodes;


use Thunder\Shortcode\Shortcode\ShortcodeInterface;


class ShortcodeExternalCaller extends Shortcode
{
  public function init() {
    // Sample read plugins config.
    // $config = (array) $this->config->get('plugins.dirlisting');
    // if ($config['builtin_js']) {
    //
    //----------
    // Register shortcode handler.
    //
    $this->shortcode->getHandlers()->add('external-caller', function(ShortcodeInterface $sc) {
      $page = $this->grav['page'];
      $root_path = getcwd();
      $page_path = $page->path();
      $plugin_path = dirname(dirname(__FILE__));
      $root_plugins_path = dirname($plugin_path);
      $stdout_output = '';
      $stderr_output = '';
      $command = trim(strip_tags($sc->getParameter('external-caller', $sc->getBbCode()))) ?: '';
      $command = str_replace('\ ', '@SPACE_HERE@', $command);
      $a_cmd = explode(' ', $command);
      $cmd_len = count($a_cmd);
      $no_prg_defined = (empty($cmd_len) or empty($a_cmd[0]));
      if (!$no_prg_defined) {
        $i = 0;
        while ($i < $cmd_len) {
          $a_cmd[$i] = $command = str_replace('@SPACE_HERE@', ' ', $a_cmd[$i]);
          $a_cmd[$i] = preg_replace('~^self://~', $plugin_path . DIRECTORY_SEPARATOR, $a_cmd[$i]);
          $a_cmd[$i] = preg_replace('~^plugin://~', $root_plugins_path . DIRECTORY_SEPARATOR, $a_cmd[$i]);
          $a_cmd[$i] = preg_replace('~^page://~', $page_path . DIRECTORY_SEPARATOR, $a_cmd[$i]);
          $a_cmd[$i] = preg_replace('~^grav://~', $root_path . DIRECTORY_SEPARATOR, $a_cmd[$i]);
          $i++;
        }
        $stdin_to_command = trim($sc->getContent());
        $stdin_before = $stdin_to_command;
        $stdin_to_command = preg_replace('~^<pre><code>~', '', $stdin_to_command);
        $stdin_to_command = preg_replace('~</code></pre>$~', '', $stdin_to_command);
        if ($stdin_to_command == $stdin_before) {
          $stdin_to_command = preg_replace('~^<p>~', '', $stdin_to_command);
          $stdin_to_command = preg_replace('~</p>$~', '', $stdin_to_command);
        }
        //
        //----------
        // Exceute command.
        //
        $descriptorspec = array(
          0 => array("pipe", "r"),  // STDIN ist eine Pipe, von der das Child liest
          1 => array("pipe", "w"),  // STDOUT ist eine Pipe, in die das Child schreibt
          2 => array("pipe", "w")   // STDERR ist eine Pipe, in die das Child schreibt
        );
        $cmd = '\'' . $command . '\'';
        $env = array(
          'ROOT_PATH' => $root_path,
          'PLUGIN_PATH' => $root_plugins_path,
          'THIS_PLUGIN_PATH' => $plugin_path,
          'PAGE_PATH' => $page_path,
          'PAGE_ROUTE' => $page->route(),
          'PAGE_URL' => $page->url(),
        );
        $environment = '';
        $process = proc_open($a_cmd, $descriptorspec, $pipes, NULL, $env);
        $error_occured = true;
        $rc = -1;
        if (is_resource($process)) {
          // Write to stdin.
          fwrite($pipes[0], $stdin_to_command);
          fclose($pipes[0]);
          // Read stdout.
          $stdout_output = trim(stream_get_contents($pipes[1]));
          fclose($pipes[1]);
          // Read stderr.
          $stderr_output = trim(stream_get_contents($pipes[2]));
          fclose($pipes[2]);
          $rc = proc_close($process);
          $error_occured = ($rc == 0) ? false : true;
        }
      }
      else {
        $error_occured = true;
        $error_message = 'No external program defined!';
      }
      //
      //----------
      // Render output.
      //
      if($error_occured) {
        $command = '"' . implode('" "', $a_cmd) . '"';
        foreach($env as $variable => $value) {
          $environment = $environment . $variable . '=' . $value . "\n";
        }
        $environment = trim($environment);
      }
      else {
        //
        //----------
        // Check if output is JSON. And matches our data scheme.
        //
        if(!empty($stdout_output)) {
          $json_value = json_decode($stdout_output);
          if(json_last_error() == JSON_ERROR_NONE) {
            $is_valid = true;
            if(!empty($json_value->{'html'})) {
              $html_output = $json_value->{'html'};
            }
            #
            $relative_plugin_path = str_replace($root_path, '', $plugin_path);
            $relative_page_path = str_replace($root_path, '', $page_path);
            #
            if(!empty($json_value->{'css'})) {
              if(is_array($json_value->{'css'})) {
                foreach($json_value->{'css'} as $uri) {
                  $uri = preg_replace('~^self://~', $relative_plugin_path . '/', $uri);
                  $uri = preg_replace('~^page://~', $relative_page_path . '/', $uri);
                  $uri = preg_replace('~^grav://~', '/', $uri);
                  $this->grav['assets']->addCss($uri);
                  #$this->grav['assets']->addCss('plugin://dirlisting/css/dirlisting.css');
                }
              }
              else {
                $is_valid = false;
              }
            }
            #
            if(!empty($json_value->{'js'})) {
              if(is_array($json_value->{'js'})) {
                foreach($json_value->{'js'} as $uri) {
                  $uri = preg_replace('~^self://~', $relative_plugin_path . '/', $uri);
                  $uri = preg_replace('~^page://~', $relative_page_path . '/', $uri);
                  $uri = preg_replace('~^grav://~', '/', $uri);
                  $this->grav['assets']->addJs($uri);
                  #$html_output = $uri;
                  #$this->grav['assets']->addJs('plugin://dirlisting/js/dirlisting.js');
                }
              }
              else {
                $is_valid = false;
              }
            }
            if($is_valid) {
              $stdout_output = $html_output;
            }
          }
        }
        //
      }
      $output = $this->twig->processTemplate('partials/external-caller.html.twig', [
        'command' => $command,
        'stdin_to_command' => $stdin_to_command,
        'plugin_directory' => __DIR__,
        'cwd' => getcwd(),
        'return_code' => $rc,
        'stderr_output' => $stderr_output,
        'stdout_output' => $stdout_output,
        'error_occured' => $error_occured,
        'error_message' => $error_occured,
        'env' => $environment,
      ]);
      return $output;
      //
    });
    //
  }  // init
  //
}  // class ShortcodeExternalCaller
?>
