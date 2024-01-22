<?php
namespace Grav\Plugin\Shortcodes;


class uLogger {
  private $log_directory = __DIR__;

  function __construct($dir = '') {
    if ($dir != '') {
      $this->log_directory = $dir;
    }
    # (1) Create logging directory.
    if (!is_dir($this->log_directory)) {
      mkdir($this->log_directory);
    }
  }

  function log() {
    if (func_num_args() == 1) {
      $logfn = $this->log_directory . DIRECTORY_SEPARATOR . date("Ymd") . '.log';
      $fp = fopen($logfn, 'a');
      foreach(preg_split("/((\r?\n)|(\r\n?))/", strval(func_get_arg(0))) as $line) {
        $line = strval(date('H:m:s') . " [" . $line. "]" . PHP_EOL);
        fwrite($fp, $line);
      }
      fclose($fp);
    } else {
      for ($i = 0; $i < func_num_args(); ++$i) {
        log(func_get_arg($i));
      }
    }
    return null;
  }  # log
}  # class uLogger
