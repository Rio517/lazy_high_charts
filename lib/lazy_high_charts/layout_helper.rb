# coding: utf-8
require 'rails' unless defined? ::Rails

module LazyHighCharts
  module LayoutHelper

    def high_chart(placeholder, object, jquery='jQuery', &block)
      if object
        object.html_options.merge!({:id=>placeholder})
        object.options[:chart][:renderTo] = placeholder
        content_for(:footer, high_graph(placeholder, object, jquery, &block))
        content_tag("div","", object.html_options)
      end
    end


  def high_graph(placeholder, object, jquery, &block)
    #Hacking in a way to pass a js date object to high_charts
    point_start = object.data.first[:pointStart]
    point_start = point_start.nil? ? '' : ",\"pointStart\": Date.UTC(#{point_start.to_s}) "
    object.data.first.reject{|k,v| k = :pointStart}
    
    graph =<<-EOJS
    <script type="text/javascript">
    #{jquery}(function() {
          // 1. Define JSON options
          var options = {
                        chart: #{object.options[:chart].to_json},
                                title: #{object.options[:title].to_json},
                                legend: #{object.options[:legend].to_json},
                                xAxis: #{object.options[:xAxis].to_json},
                                yAxis: #{object.options[:yAxis].to_json},
                                tooltip:  #{object.options[:tooltip].to_json},
                                credits: #{object.options[:credits].to_json},
                                plotOptions: #{object.options[:plotOptions].to_json},
                                series: #{object.data.to_json.insert(-3, point_start)},
                                subtitle: #{object.options[:subtitle].to_json}
                        };

          // 2. Add callbacks (non-JSON compliant)
          #{capture(&block) if block_given?}
          // 3. Build the chart
          var chart = new Highcharts.Chart(options);
      });
      </script>
    EOJS

    if defined?(raw) &&  ::Rails.version >= '3.0'
      return raw(graph) 
    else
      return graph unless block_given?
      concat graph
    end
  end    

  end
end
