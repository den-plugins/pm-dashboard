function plot_chart(data){
  var plot1 = jQuery.jqplot ('jchart', data, {
    series: [
      {label:'Ideal', markerOptions: { style:'x' }},
      {label:'Actual'}
    ],
    legend: { show: true},
    axesDefaults: {
      tickRenderer: jQuery.jqplot.CanvasAxisTickRenderer,
      tickOptions: {fontSize: '7pt'}
    },
    axes: {
      xaxis: { label: "Dates", renderer: jQuery.jqplot.DateAxisRenderer, tickOptions: { angle: -60}},
      yaxis: { label: "Hours/Story Points", labelRenderer: jQuery.jqplot.CanvasAxisLabelRenderer }
    },
    highlighter: { show: true, sizeAdjust: 7.5 },
    cursor:{ show: true, zoom: true }
  });
  jQuery('.button-reset').click(function() { plot1.resetZoom() });
}
