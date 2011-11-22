function plot_cost(id, data){
var plot = jQuery.jqplot(id, data, { 
	seriesDefaults: {      
	  renderer:jQuery.jqplot.BarRenderer,
      pointLabels: { show: true, location: 'e'},
      rendererOptions: {barDirection: 'horizontal', shadowOffset: 0, barPadding: -40}
    },
    series: [
      {label: "Baseline Amount (Budget)"},
      {label: "Forecast"},
      {label: "Actuals"}
    ],
    axes: {      yaxis: {renderer: jQuery.jqplot.CategoryAxisRenderer}    },
    legend: {show: true, location: 'ne'},
    grid: {gridLineColor: '#f2f2f2'}  });
}
