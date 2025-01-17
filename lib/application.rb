class Application
  def self.pretty_datetime(time)
    return nil if time.nil?

    format = "%Y-%m-%d at %H:%M:%S %Z".freeze

    if time.respond_to? :strftime
      time.strftime(format)
    else
      Time.parse(time).strftime(format)
    end
  end

  def self.state_links
    State.all_states.map do |state|
      <<~HTML
        <li><a href="/#{state.parameterize}">#{state.state_name}</a></li>
      HTML
    end.join("\n")
  end


  def self.payload(class_name)
    <<~HTML
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="UTF-8">
      <title>#{class_name ? class_name.state_name + " " : nil}Ovid COVID-19 report</title>
      <style type="text/css">
        #{css}
      </style>
      <script type="text/javascript">
        #{javascript}
      </script>
    </head>
    <body>
      <nav>
        <ul>
          <li><a href="/">Home</a></li>
          #{state_links}
        </ul>
      </nav>

      #{class_name ? state_page(class_name) : home_page}

      <hr />
      <p>
        <a href="https://github.com/olivierlacan/ovid/">Source code for this website</a>
         - Maintained by <a href="https://olivierlacan.com">Olivier Lacan</a> for <a href="https://covidtracking.com/">The COVID Tracking Project</a>
      </p>
    </body>
    </html>
    HTML
  end

  def self.home_page
    <<~HTML
      <h1>Ovid</h1>
      <p>
        This project aggregates county-level data from U.S. states for
        which ArcGIS public Feature Layers (datasets) are available.
      </p>

      <p>
        While this data may not always be authoritative, it allows for
        COVID-19 case and testing information released by states in
        other avenues to be compared with raw data emanating from their
        own counties.
      </p>

      <p>
        Please corroborate this data prior to use in any journalistic or
        data scientific endeavor. State pages link to ArcGIS dashboards
        whenever possible and the source feature layers are listed to
        help independent
        verification.
      </p>
    HTML
  end

  def self.case_report(class_name)
    return nil if class_name.cases_feature_url.nil?
    title = "Data Aggregated from Individual Cases"

    payload = <<~HTML
      <h2>#{title}</h2>
      <p>
        Source: <a href="#{class_name.cases_feature_url}">ArcGIS Feature Layer</a>.<br />
    HTML

    case_report = class_name.case_report

    if case_report.has_key?(:edited_at) && case_report.has_key?(:fetched_at)
      last_edit = pretty_datetime case_report[:edited_at]
      last_fetch = pretty_datetime case_report[:fetched_at]

      payload << <<~HTML
          Edited by #{class_name::ACRONYM} at <strong>#{last_edit}</strong>.<br />
          Fetched at <strong>#{last_fetch}</strong><br />
        </p>
      HTML
    end

    if case_report&.public_send(:[],:refreshing)
      payload << "Fetching new data from FDOH, please refresh in 1 minute..."
    else
      payload << <<~HTML

        #{report_table(case_report, title, class_name, last_fetch)}
      HTML
    end

    payload
  end

  def self.generic_report(class_name, type, title, source_title, source_url)
    report = class_name.report(type)
    return nil if report&.public_send(:[],:data).nil?

    last_edit = pretty_datetime report.fetch(:edited_at) { nil }
    last_fetch = pretty_datetime report[:fetched_at]

    <<~HTML
      <h2>#{title}</h2>
      <p>
        Source: <a href="#{source_url}">#{source_title}</a>.<br />
        #{last_edit ? "Source last updated at <strong>#{last_edit}</strong>.<br />" : nil }
        Fetched at <strong>#{last_fetch}</strong>.<br />
      </p>
      #{report_table(report, title, class_name, last_fetch)}
    HTML
  end

  def self.state_page(class_name)
    <<~HTML
      <h1>#{class_name.state_name} COVID-19 Report</h1>
      <p>
        This report is generated from the same data used to generate the
        <a href="#{class_name.dashboard_url}"> ArcGIS dashboard</a>.
      </p>

      #{generic_report(class_name, :totals, "State Level Totals", "AHCA Hospital Bed Capacity by County", class_name.totals_feature_url)}
      #{case_report(class_name)}
      #{generic_report(class_name, :county, "Data Aggregated from County Totals", "ArcGIS Feature Layer", class_name.counties_feature_url)}
      #{generic_report(class_name, :covid_hospitalizations, "Current COVID-19 Hospitalizations", "AHCA COVID-19 Hospitalizations by County", class_name.covid_hospitalizations_county_url)}
      #{generic_report(class_name, :beds, "Current Hospital Bed Capacity", "AHCA Hospital Bed Capacity by County", class_name.beds_county_current_url)}
      #{generic_report(class_name, :icu, "Current Hospital ICU Capacity", "AHCA Hospital ICU Capacity by County", class_name.icu_county_current_url)}
      #{generic_report(class_name, :hospitals, "Hospitalization Totals", "ArcGIS Feature Layer", class_name.hospitals_feature_url)}
    HTML
  end

  def self.percentage_tally(values)
    size = values.compact.size
    compacted_values = values.compact

    max = compacted_values.max
    min = compacted_values.min
    average = compacted_values.inject{ |sum, el| sum + el }.to_f / size

    <<~STRING
      Min:&nbsp;#{(min * 100).truncate(2)}%\n
      Max:&nbsp;#{(max * 100).truncate(2)}%\n
      Avg:&nbsp;#{(average * 100).truncate(2)}%\n
    STRING
  end

  def self.report_table(report, title, class_name, last_fetch)
    timestamp = DateTime.parse(last_fetch).iso8601.gsub(":", "-")
    filename = "#{class_name.to_s.downcase}_#{title.downcase.gsub(/\s/, '_')}"
    table_identifier = "#{filename}_#{timestamp}"

    rows = report[:data].map do |_key, metric|
      positive_value = metric[:positive_value] ? "Positive value: #{metric[:positive_value]}" : nil
      value = metric[:percentage] ? percentage_tally(metric[:value]) : metric[:value]
      <<~HTML
        <tr>
          <td title="#{metric[:source]}">#{metric[:name]}</td>
          <td class="#{'highlight' if metric[:highlight]}">#{value}</td>
          #{report[:show_source] ? "<td title='#{positive_value}'>#{metric[:source]}</td>" : nil}
          <td>#{metric[:description]}</td>
        </tr>
      HTML
    end.join("\n")

    output = <<~HTML
      <table id="#{table_identifier}">
        <tr>
          <th title="The metric represented by this value.">Metric</th>
          <th title="The raw or computed value for this metric.">Value</th>
          #{report[:show_source] ? '<th title="The source field name used to extract this value">Source</th>' : nil}
          <th title="Descriptions are either source from available data definitions or inferred/corroborated with external sources.">Description</th>
        </tr>
        #{rows}
      </table>
      <a href="#" onclick="download_table_as_csv('#{table_identifier}');">Download as CSV</a>
    HTML
  end

  def self.javascript
    <<~JAVASCRIPT
      function download_table_as_csv(table_id) {
        // Select rows from table_id
        var rows = document.querySelectorAll('#' + table_id + ' tbody tr');
        // Construct csv
        var csv = [];
        for (var i = 0; i < rows.length; i++) {
          var row = [], cols = rows[i].querySelectorAll('td, th');
          for (var j = 0; j < cols.length; j++) {
            // Clean innertext to remove multiple spaces and jumpline (break csv)
            var data = cols[j].innerText.replace(/(\\r\\n|\\n|\\r)/gm, '').replace(/(\\s\\s)/gm, ' ');
            // Escape double-quote with double-double-quote (see https://stackoverflow.com/questions/17808511/properly-escape-a-double-quote-in-csv)
            data = data.replace(/"/g, '""');
            // Push escaped string
            row.push('"' + data + '"');
          }
          csv.push(row.join(","));
        }
        var csv_string = csv.join('\\n');
        // Download it
        var filename = table_id + '.csv';
        var link = document.createElement('a');
        link.style.display = 'none';
        link.setAttribute('target', '_blank');
        link.setAttribute('href', 'data:text/csv;charset=utf-8,' + encodeURIComponent(csv_string));
        link.setAttribute('download', filename);
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
      }
    JAVASCRIPT
  end

  def self.css
    <<~CSS
      body {
        font-family: Tahoma, sans-serif;
      }

      nav ul {
        padding: 0;
      }
      nav li {
        list-style: none;
        display: inline-block;
      }

      table {
        width: 100%
      }
      th, td {
        padding: 0.3rem 1rem;
      }

      th {
        position: sticky;
        top: 15px;
        background: white;
      }

      td:first-child, th:first-child {
        text-align: right;
        width: 25%;
      }

      td:nth-child(2), th:nth-child(2) {
        text-align: right;
        width: 5%;
      }

      td:last-child, th:last-child {
        text-align: left;
        width: 70%;
      }

      tr:nth-child(even) { background: #CCC }
      tr:nth-child(odd) { background: #FFF }

      .highlight { font-weight: bold; }
    CSS
  end
end
