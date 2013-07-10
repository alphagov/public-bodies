function drawGroupedBar(err, json) {
    if(err) {
	alert(err);
	return;
    }

    var svg = d3.select('svg.groupedbar');
    
    var box = svg[0][0].viewBox.baseVal;
    var width = box.width;
    var height = box.height;

    var departments = json['all_bodies'];


    var bodies = [];
    var departmentsUnlabelled = departments.map(function (d) { return d.values });
    bodies = bodies.concat.apply(bodies, departmentsUnlabelled).filter(function(d) { return d['government-funding'] > 0}).sort(function (a, b) { return a['government-funding'] - b['government-funding']})
    var bodyStrings = bodies.map(function (d) { return d.name });
    var bodyValues = bodies.map(function (d) { return parseInt(d['government-funding'])});
    var barScale = d3.scale.ordinal().domain(bodyStrings).rangeRoundBands([30, width-30]);
    var heightScale = d3.scale.log().domain([1, 6846711000]).range([30, height-30]);
    var bargroup = svg.append('g');

    var colScale = chroma.scale(['red', 'black']);

    
    bargroup.selectAll('rect')
	.data(bodies)
	.enter()
	.append('rect')
	.attr('x', function(d) { return barScale(d.name) })
    	.attr('y', function(d) { return heightScale(6846711000) - heightScale(d['government-funding']) })
    	.attr('width', 2)
    	.attr('height', function(d) { return heightScale(d['government-funding']) })
	.style('stroke', 'none')
    	.style('fill', function(d) { return colScale.get(parseInt(d['government-funding'])).hex() } );

    
    
}
$(function() { d3.json('index.json', drawGroupedBar); })
