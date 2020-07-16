#!/usr/bin/ruby
#
=begin
Copyright (c) 2020, Kai Thoene

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
=end
#
#----------
# Set some global variables.
#
$g_me = $PROGRAM_NAME.to_s
$g_myname = File.basename($g_me)
$g_mydir = File.dirname($g_me)
$g_absmydir = File.absolute_path($g_mydir)
#
#----------
# Load needed modules.
#
require 'yaml'
require 'json'
require 'securerandom'
require 'redcarpet'
#
#----------
# Colors.
#
COLORS = [
  '#008395',
  '#00007B',
  '#95D34F',
  '#F69EDB',
  '#D311FF',
  '#7B1A69',
  '#F61160',
  '#FFC183',
  '#232308',
  '#8CA77B',
  '#F68308',
  '#837200',
  '#72F6FF',
  '#9EC1FF',
  '#72607B',
  '#0000FF',
  '#FF0000',
  '#00FF00',
  '#00002B',
  '#FF1AB8',
  '#FFD300',
  '#005700',
  '#8383FF',
  '#9E4F46',
  '#00FFC1',
].freeze
#
#----------
# Functions.
#
def get_lat_long_zoom(data_p, default_zoom_p = 16)
  # Example: "52.05551,8.36240?z=18"
  a_da = data_p.split(/[,?]/)
  if (2..3).include?(a_da.length)
    lat = a_da[0].to_f
    long = a_da[1].to_f
    zoom = default_zoom_p
    if a_da[2] =~ /^z=(\d+)/
      zoom = Regexp.last_match(1).to_i
      zoom = default_zoom_p if zoom < 0
    end
    return lat, long, zoom
  end
  raise "#{File.join($g_absmydir, $g_myanme)}: Invalid geo entry! GEO='#{data_p}'"
end #get_lat_long_zoom

#
#----------
# START HERE.
#
#
#----------
# TODO: Improve this!
#
def check_parameter(hash_p, key_p, lambda_p)
  value = hash_p[key_p.to_s]
  emsg, hash_p[key_p.to_s] = lambda_p.call(key_p.to_s, hash_p[key_p.to_s])
  emsg = "Not String. Invalid map #{key_p}! #{key_p.to_s.upcase}=#{value.inspect}" unless hash_p[key_p.to_s].is_a?(String)
  emsg.to_s
end # check_parameter
#
#----------
# Load available locales, if any.
#
available_locales = [ 'en' ]
dir_locales = File.join($g_mydir, 'locales')
Dir.glob(File.join(dir_locales, '*.yml')) do |loc_fn|
  locale = File.basename(loc_fn, '.*')
  available_locales.push(locale) unless available_locales.include?(locale)
end
#
#----------
# Check given YAML file.
#
begin
  markdown_renderer = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true)
  input = ''
  $stdin.each_line { |line| input += line }
  data = YAML.load(input)
  #
  #----------debug
  # Syntax checking of data.
  #
  emsg = ''
  loop do
    emsg = "Not Hash. Invalid YAML data! DATA=#{data.inspect}" unless data.is_a?(Hash)
    break unless emsg.empty?
    # Trim all values.
    data.each_key { |key| data[key] = data[key].strip if data[key].is_a?(String) }
    # provider
    emsg += check_parameter(data, :provider, lambda { |name, value|
      value = 'leaflet' if value.to_s.empty?
      emsg = "Invalid map #{name}! #{name.upcase}=#{value.inspect}" if value != 'leaflet'
      [emsg, value]
    })
    break unless emsg.empty?
    # locale
    emsg += check_parameter(data, :locale, lambda { |name, value|
      value = 'en' if value.to_s.empty?
      emsg = "Invalid map #{name}! #{name.upcase}=#{value.inspect}" if !available_locales.include?(value)
      [emsg, value]
    })
    break unless emsg.empty?
    # geo
    emsg += check_parameter(data, :geo, lambda { |name, value|
      value = '' if value.to_s.empty?
      emsg = "Invalid map #{name}! #{name.upcase}=#{value.inspect}" unless value =~ /^[+-]?\d+(\.\d+)?,[+-]?\d+(\.\d+)?(\?z=\d+){0,1}$/
      [emsg, value]
    })
    break unless emsg.empty?
    # width
    emsg += check_parameter(data, :width, lambda { |name, value|
      value = '' if value.to_s.empty?
      if value.to_s =~ /^\d+$/
        emsg = "Invalid map #{name}! Must be greater then zero! #{name.upcase}=#{value.inspect}" if value.to_s.to_i.zero?
      else
        emsg = "Invalid map #{name}! #{name.upcase}=#{value.inspect}"
      end
      [emsg, value.to_s]
    })
    break unless emsg.empty?
    # height
    emsg += check_parameter(data, :height, lambda { |name, value|
      value = '' if value.to_s.empty?
      if value.to_s =~ /^\d+$/
        emsg = "Invalid map #{name}! Must be greater then zero! #{name.upcase}=#{value.inspect}" if value.to_s.to_i.zero?
      else
        emsg = "Invalid map #{name}! #{name.upcase}=#{value.inspect}"
      end
      [emsg, value.to_s]
    })
    break unless emsg.empty?
    unless data['poi'].nil?
      poi = data['poi']
      if poi.is_a?(Array)
        poi.each do |single_poi|
          if single_poi.is_a?(Hash)
            # Check if String.
            single_poi.each_key do |key|
              emsg += "POI #{key} is not a String! POI-#{key.to_s.upcase}=#{single_poi[key].inspect}" unless single_poi[key].is_a?(String)
              break unless emsg.empty?
            end
            unless emsg.empty?
              # Trim all.
              single_poi.each_key { |key| single_poi[key] = single_poi[key].strip }
              # geo
              emsg += check_parameter(single_poi, :geo, lambda { |name, value|
                value = '' if value.to_s.empty?
                emsg = "Invalid POI #{name}! #{name.upcase}=#{value.inspect}" unless value =~ /^[+-]?\d+(\.\d+)?,[+-]?\d+(\.\d+)?$/
                [emsg, value]
              })
              break unless emsg.empty?
              # anchor
              emsg += check_parameter(single_poi, :anchor, lambda { |name, value|
                value = '' if value.to_s.empty?
                emsg = "Invalid POI #{name}! #{name.upcase}=#{value.inspect}" if value =~ /\s/
                [emsg, value]
              })
              break unless emsg.empty?
            end
          else
            emsg = "Invalid map POI! Not Hash. POI=#{single_poi.inspect}"
            break unless emsg.empty?
          end
        end
        break unless emsg.empty?
      else
        emsg += "Invalid map POI! Not Array. POI=#{poi.inspect}"
        break unless emsg.empty?
      end
    end
    break
  end
  unless emsg.empty?
    warn emsg
    exit 1
  end
  #
  #----------
  # Load translations, if any.
  #
  fn_transl = File.join($g_mydir, 'locales')
  if Dir.exist?(fn_transl)
    begin
      require 'fast_gettext'
      FastGettext.add_text_domain('app', path: fn_transl, type: :yaml)
      FastGettext.text_domain = 'app'
      FastGettext.available_locales = available_locales
      FastGettext.locale = data['locale']
      include FastGettext::Translation
    rescue => e
      require File.join($g_mydir, 'zero-translation.rb')
      include ZeroGettext::Translation
    end
  else
    require File.join($g_mydir, 'zero-translation.rb')
    include ZeroGettext::Translation
  end
  #
  #----------
  # Map variable names.
  #
  maphex = SecureRandom.hex
  mapid = "map-#{maphex}"
  mapvar = "map_#{maphex}"
  latitude, longitude, zoom_factor = get_lat_long_zoom(data['geo'])
  #
  #----------
  # Render markers.
  #
  initial_description_marker_font_size = 14
  initial_map_marker_font_size = 17
  initial_map_marker_bottom_position = -5
  marker = '' # <= These become the markers.
  a_poi_table = []
  marker_pre = ''
  n_index = 1
  n_marker = 1
  n_color = 0
  data['poi'].each do |poi|
    next unless poi['geo']
    lat, lon, _zoom = get_lat_long_zoom(poi['geo'])
    moptions = ''
    msubopt = ''
    msubopt += "title: '#{poi['name']}', " if poi['name']
    m_color = (poi['color'].to_s.empty? ? COLORS[n_color % COLORS.length] : poi['color'])
    badge = (poi['badge'].to_s.empty? ? n_marker.to_s : poi['badge'].to_s)
    # Get length of number.
    n_len = badge.length
    m_fsize = (initial_map_marker_font_size * (1.0 - 0.18 * (n_len - 1))).floor
    m_fsize = 6 if m_fsize < 6
    m_bottom_pos = initial_map_marker_bottom_position + ((initial_map_marker_font_size - m_fsize) / 2).ceil
    m_bottom_pos += 2 if (m_bottom_pos - initial_map_marker_bottom_position) >= 2
    m_pre = <<EOF
      var icon_#{n_index}_#{maphex} = L.divIcon({
				className: 'custom-div-icon', iconSize: [30, 42], iconAnchor: [15, 42],
        html: '<div style="background-color:#{m_color};" class="marker-pin"></div><span class="marker-number" style="font-size:#{m_fsize}px; bottom:#{m_bottom_pos}px;">#{badge}</span>',
      });
EOF
    marker_pre += (marker_pre.empty? ? "\n" : '') + m_pre
    msubopt += "icon: icon_#{n_index}_#{maphex}, "
    moptions = "{ #{msubopt}}" unless msubopt.empty?
    marker += (marker.empty? ? '' : "\n") + "      L.marker([#{lat}, #{lon}]#{moptions.empty? ? '' : ", #{moptions}"}).addTo(#{mapvar});"
    # Get length of number.
    n_len = badge.length
    m_fsize = (initial_description_marker_font_size * (1.0 - 0.12 * n_len)).floor
    m_fsize = 6 if m_fsize < 6
    # Push POI for table.
    a_poi_table.push([
                       # Replica of marker, with optional anchor.
                       "<span #{poi['anchor'].to_s.empty? ? '' : "id=\"#{poi['anchor']}\" "}class=\"marker-icon-a\"><div style=\"background-color:#{m_color};\" class=\"marker-pin-a\"><div class=\"number\" style=\"font-size:#{m_fsize}px;\">#{badge}</div></div></span>",
                       # Rendered description.
                       (poi['description'].to_s.empty? ? '' : markdown_renderer.render(poi['description'])),
                       # Geo-location link.
                       "<p><a href=\"geo:#{lat},#{lon}\">geo:#{lat},#{lon}</a></p>",
                     ])
    #
    n_color += 1 if poi['color'].to_s.empty?
    n_marker += 1 if poi['badge'].to_s.empty?
    n_index += 1
  end
  #
  #----------
  # Render map.
  #
  map_content = <<EOF
    <style>
      span.color-box {
        display: inline-block;
        width: 0.8em;
        height: 0.8em;
        border-top: 1px solid rgba(0, 0, 0, .2);
        border-left: 1px solid rgba(0, 0, 0, .2);
        border-bottom: 1px solid rgba(0, 0, 0, .2);
      }
      /* ----------
         | SEE:https://www.geoapify.com/create-custom-map-marker-icon/
         | SEE:https://jsfiddle.net/a08oek3w/2/
         ---------- */
      .marker-pin {
        width: 30px;
        height: 30px;
        border-radius: 50% 50% 50% 0;
        background: #c30b82;
        position: absolute;
        transform: rotate(-45deg);
        left: 50%;
        top: 50%;
        margin: -15px 0 0 -15px;
      }
      .marker-pin::after {
        content: '';
        width: 24px;
        height: 24px;
        margin: 3px 0 0 3px;
        background: #fff;
        position: absolute;
        border-radius: 50%;
      }
      .custom-div-icon span {
        position: absolute;
        width: 22px;
        font-size: 22px;
        left: 0;
        right: 0;
        margin: 10px auto;
        text-align: center;
        bottom: -5px;
      }
      .custom-div-icon span.marker-number {
        margin: 12px auto;
        font-size: 17px;
      }
      /* ---------- */
      .marker-icon-a {
        display: inline-block;
        position: relative;
        top: -10px;
      }
      .marker-pin-a {
        width: 24px;
        height: 24px;
        border-radius: 50% 50% 50% 0;
        background: #c30b82;
        position: relative;
        top: +8px;
        transform: rotate(-45deg);
      }
      .marker-pin-a::after {
        content: '';
        width: 18px;
        height: 18px;
        margin: 3px 0 0 3px;
        left: 0px;
        background: #fff;
        position: absolute;
        border-radius: 50%;
      }
      .marker-icon-a div.number {
        position: relative;
        display: inline-block;
        transform: rotate(45deg);
        /*background-color: red;*/
        width: 24px;
        font-size: #{initial_description_marker_font_size}px;
        top: -1px;
        left: -1px;
        margin: 0;
        text-align: center;
        z-index: 202;
      }
      ##{mapid} {
        width:#{data['width']}px;
        height:#{data['height']}px;
      }
    </style>
    <div id="#{mapid}"></div>
    <script type="text/javascript">
      var #{mapvar} = L.map('#{mapid}').setView([#{latitude}, #{longitude}], #{zoom_factor});
      L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> #{_('contributors')}'
      }).addTo(#{mapvar});#{marker_pre}#{marker}
    </script>
EOF
  poi_table_content = ''
  n_marker = 1
  a_poi_table.each do |poi_tr|
    if poi_table_content.empty?
      poi_table_content = <<EOF
      <table><thead>
        <tr>
          <th>#{_('Marker')}</th>
          <th>#{_('Description')}</th>
          <th>#{_('Location')}</th>
        </tr>
      </thead>
      <tbody>
EOF
    end
    poi_table_content += <<EOF
        <tr>
          <td style="text-align:center;">#{poi_tr[0]}</td>
          <td>#{poi_tr[1]}</td>
          <td>#{poi_tr[2]}</td>
        </tr>
EOF
    n_marker += 1
  end
  poi_table_content += "      </tbody></table>\n" unless poi_table_content.empty?
  #
  #----------
  # Output redered content.
  #
  html_output = ''
  html_output += map_content unless map_content.empty?
  html_output += poi_table_content unless poi_table_content.empty?
  #
  #----------
  # Return it as JSON.
  #
  puts JSON.generate({
                       html: html_output,
                       css: %w[https://unpkg.com/leaflet@1.6.0/dist/leaflet.css],
                       js: %w[https://unpkg.com/leaflet@1.6.0/dist/leaflet.js],
                     })
  #
end
exit 0
