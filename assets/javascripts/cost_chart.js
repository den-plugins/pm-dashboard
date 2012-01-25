function plot_cost(id, data){
	var ticks = ['Baseline Amount (Budget)', 'Actual', 'Forecast'];
	var plot1 = jQuery.jqplot(id, [data], {
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
    seriesColors: [ "#5296d9", "#dc594e", "#66c566"],
	highlighter: { show: false },
	grid: {gridLineColor: '#f2f2f2'}  });
}
