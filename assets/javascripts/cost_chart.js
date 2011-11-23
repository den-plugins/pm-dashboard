function plot_cost(id, data){
var ticks = ['Baseline Amount (Budget)', 'Forecast', 'Actual'];

var plot1 = jQuery.jqplot(id, [data], {
// Only animate if we're not using excanvas (not in IE 7 or IE 8)..
animate: !jQuery.jqplot.use_excanvas,
seriesDefaults:{
    renderer:jQuery.jqplot.BarRenderer,
    rendererOptions:{ varyBarColor : true },
    pointLabels: { show: true }
},
axes: {
    xaxis: {
        renderer: jQuery.jqplot.CategoryAxisRenderer,
        ticks: ticks
    }
},
highlighter: { show: false },
grid: {gridLineColor: '#f2f2f2'}  });
}
     








    
