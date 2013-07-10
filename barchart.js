function drawChart(err, json) {
    if(err) {
	alert(err);
	return;
    }

    var departments = json['all_bodies'];

    var total = 0;
    var merged = 0;
    var abolished = 0;

    for (departmentID in departments) {
	if (typeof department !== 'function') {
	    var department = departments[departmentID];
	    for(bodyID in department) {
		var body = department[bodyID];
		total += 1;
		if(body['pb-reform'] == 'merge') {
		    merged += 1;
		}
		else if (body['pb-reform'] != 'retain') {
		    abolished += 1;
		}
	    }
	}
    }


    var svg = d3.select('svg.barchart');

    var box = svg[0][0].viewBox.baseVal;
    var width = box.width;
    var height = box.height;
    
    
    var barData = [
	{name : 'Original Total (2009)', value : total},
	{name : 'Abolished', value : abolished},
	{name : 'Merged', value : merged},
	{name : 'Retained', value : total-abolished}
    ];

    
    var widthScale = d3.scale.linear().domain([0, barData.length]).rangeRound([25, height-25]);
    var heightScale = d3.scale.linear().domain([0, total]).rangeRound([170, width-20]);

    var lines = svg.append('g');
    var bars = svg.append('g');


    var barwidth = height / (2 * barData.length);

    var ticks = 15;
    
    lines.selectAll('line')
	.data(heightScale.ticks(ticks))
	.enter()
	.append('line')
	.attr('x1', function(d) { return heightScale(d) })
	.attr('x2', function(d) { return heightScale(d) })
	.attr('y1', function(d) { return 0 })
	.attr('y2', function(d) { return height-25 })
	.style('stroke', function(d, i) { if(i == 0) { return 'black' } else { return '#ccc' }});


    lines.selectAll('text')
	.data(heightScale.ticks(ticks))
	.enter()
	.append('text')
	.attr('x', function(d) { return heightScale(d) })
	.attr('y', function(d) { return height - 15 })
	.text(String)
	.attr('dominant-baseline' , 'mathematical')
	.attr('text-anchor' , 'middle');

    bars.selectAll('rect')
	.data(barData)
	.enter()
	.append('rect')
	.style('stroke', 'none')
	.style('fill', 'steelblue')
	.attr('width', function(d, i) { return heightScale(d.value) - 170; })
	.attr('height', function(d, i) { return barwidth; })
	.attr('y', function(d, i) { return widthScale(i)})
	.attr('x', function(d, i) { return heightScale(0) })
	.style('stroke', 'black');


    bars.selectAll('text')
	.data(barData)
	.enter()
	.append('text')
	.attr('y', function(d, i) { return widthScale(i) + (barwidth / 2);})
	.attr('x', function(d, i) { return heightScale(0) - 20 })
	.text(function(d) { return d.name })
	.attr('dominant-baseline' , 'middle')
	.attr('text-anchor' , 'end');
}
$(function() { d3.json('index.json', drawChart); })
