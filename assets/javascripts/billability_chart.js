function plot_chart(data){
    var plot1 = jQuery.jqplot ('jchart', data, {
      axes: {
        // options for each axis are specified in seperate option objects.
        xaxis: {
          label: "Dates",
          renderer: jQuery.jqplot.DateAxisRenderer,
          tickOptions: {
            fontSize: '8pt'
          }
        },
        yaxis: {
          label: "Billability (%)",
          labelRenderer: jQuery.jqplot.CanvasAxisLabelRenderer
        }
      },
      highlighter: {
        show: true,
        sizeAdjust: 7.5
      }, 
      cursor:{ 
        show: true,
        zoom: true
      } 
    });
}
