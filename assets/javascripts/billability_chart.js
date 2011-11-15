function plot_chart(id, data){
    var plot1 = jQuery.jqplot (id, data, {
      axes: {
        // options for each axis are specified in seperate option objects.
        xaxis: {
          label: "Dates",
          renderer: jQuery.jqplot.DateAxisRenderer,
          tickOptions: {
            showMark: false,
            fontSize: '8pt'
          },
          tickInterval: "14 days"
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
