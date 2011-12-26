function plot_billability(id, data){
    var plot1 = jQuery.jqplot (id, data, {
      axes: {
        // options for each axis are specified in seperate option objects.
        xaxis: {
          label: "Dates",
          renderer: jQuery.jqplot.DateAxisRenderer,
          tickOptions: {
            showMark: false,
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

function plot_monthly_billability(id, data) {
  var plot2 = jQuery.jqplot(id, data, {
    axes: {
      xaxis: {
        label: "Months",
        renderer: jQuery.jqplot.DateAxisRenderer,
        tickOptions: {showMark: false, fontSize: '8pt', formatString: '%b %Y'}
      },
      yaxis: {
        label: "Billability (%)",
        labelRenderer: jQuery.jqplot.CanvasAxisLabelRenderer
      }
    },
    highlighter: { show: true, sizeAdjust: 7.5 },
    cursor: {show: true, zoom: true }
  });
}
