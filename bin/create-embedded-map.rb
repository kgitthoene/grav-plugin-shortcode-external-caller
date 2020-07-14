#!/usr/bin/ruby
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
"#008395",
"#00007B",
"#95D34F",
"#F69EDB",
"#D311FF",
"#7B1A69",
"#F61160",
"#FFC183",
"#232308",
"#8CA77B",
"#F68308",
"#837200",
"#72F6FF",
"#9EC1FF",
"#72607B",
"#0000FF",
"#FF0000",
"#00FF00",
"#00002B",
"#FF1AB8",
"#FFD300",
"#005700",
"#8383FF",
"#9E4F46",
"#00FFC1",
]
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
      zoom = $1.to_i
      zoom = default_zoom_p if zoom < 0
    end
    return lat, long, zoom
  end
  raise "#{File.join($g_absmydir, $g_myanme)}: Invalid geo entry! GEO='#{data_p}'"
end  #get_lat_long_zoom
#
#----------
# START HERE.
#
begin
  markdown_renderer = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true)
  input = ''
  $stdin.each_line { |line| input += line }
  data = YAML.load(input)
  #
  #----------
  # TODO: Syntax checking of data.
  #
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
  marker = ''  # <= These become the markers.
  a_poi_table = []
  marker_pre = ''
  n_index = 1
  n_marker = 1
  n_color = 0
  data['poi'].each do |poi|
    if poi['geo']
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
      m_pre =<<EOF
      var icon_#{n_index}_#{maphex} = L.divIcon({
				className: 'custom-div-icon', iconSize: [30, 42], iconAnchor: [15, 42],
        html: '<div style="background-color:#{m_color};" class="marker-pin"></div><span class="marker-number" style="font-size:#{m_fsize}px; bottom:#{m_bottom_pos}px;">#{badge}</span>',
      });
EOF
      marker_pre += (marker_pre.empty? ? "\n" : '') + m_pre
      msubopt += "icon: icon_#{n_index}_#{maphex}, "
      moptions = "{ #{msubopt}}" if !msubopt.empty?
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
        attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
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
          <th>Marker</th>
          <th>Description</th>
          <th>Location</th>
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
  poi_table_content +="      </tbody></table>\n" if !poi_table_content.empty?
  #
  #----------
  # Output redered content.
  #
  html_output = ''
  html_output += map_content if !map_content.empty?
  html_output += poi_table_content if !poi_table_content.empty?
  #
  #----------
  # Return it as JSON.
  #
  puts JSON.generate({
    html: html_output,
    css: %W(https://unpkg.com/leaflet@1.6.0/dist/leaflet.css),
    js: %W(https://unpkg.com/leaflet@1.6.0/dist/leaflet.js),
  })
  #
end
exit 0
