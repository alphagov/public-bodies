function InteractiveBarChart(svg) {
    return {

	last : '',
	showedZero : false,
	rects : undefined,
	width : svg[0][0].viewBox.baseVal.width,
	height : svg[0][0].viewBox.baseVal.height,
	barGroup : svg.append('g'),


	drawBars : function(field, log, showZero, departments) {
	    var showZeroChanged = showZero == this.showedZero;
	    var fieldChanged = this.last == field;

	    
	    var barGroup = this.barGroup;
	    var height = this.height;
	    var width = this.width;

	    var processfunc = log? Math.log : Number
	    var bodies = [].concat.apply([], departments).filter(function(d) { return showZero ||  d[field] > 0}).sort(function (a, b) { return a[field] - b[field]})

	    var bodyStrings = bodies.map(function (d) { return d.name });
	    var barScale = d3.scale.ordinal().domain(bodyStrings).rangeRoundBands([0, width]);
	    
	    var bodyValues = bodies.map(function (d) { return parseInt(d[field])});

	    var max = Math.max.apply(Math, bodyValues)

	    var heightScale;
	    if(log) {
		heightScale = d3.scale.log().domain([1, max]).range([30, height-30]);
	    } else {
		heightScale = d3.scale.linear().domain([1, max]).range([30, height-30]);
	    }

	    var colScale = chroma.scale(['steelblue', 'red']).domain([processfunc(1), processfunc(max)]);

	    if(this.last != field || showZero != this.showedZero) {
		rects = barGroup.selectAll('rect')
		    .data(bodies);

		rects.exit()
		    .remove();

		rects
		    .enter()
		    .append('rect');

	    }
	    rects
    		.attr('width', barScale.rangeBand())
		.attr('data-name', function(d) { return d['name'] })
    		.attr('data-value', function(d) { return d[field] })
		.style('stroke', 'white')
    		.style('fill', function(d) { return colScale(processfunc(parseInt(d[field]))).hex() } )
		.attr('x', function(d) { return barScale(d.name) })
		.on("mouseenter", function(d) {
		    d3.select('body').append('div')
			.attr('class', 'tooltip')
			.style("position", "absolute")
			.style('left', d3.event.pageX + 'px')
			.style('top', (d3.event.pageY + 5) + 'px')
			.append('p').text(d['name'])
			.append('p').text(d[field]);
		})
		.on("mouseleave", function(d) {
		    d3.select('.tooltip').remove();
		})
		.on("click", function(d) {
		    window.location.href = d['clean-department'] + '/' + d['clean-name'] + '.html'
		})
	    
	    if(this.last != field) {
		rects
		    .attr('y', heightScale(max))
		    .attr('height', 0)
	    }
	    rects
		.transition()
		.delay(function(d,i) { return i * 1 })
		.attr('y', function(d) { return heightScale(max) - heightScale(d[field]) })
		.attr('height', function(d) { return heightScale(d[field]) })
	    ;
	    last = field;
	    showedZero = showZero;
	}
    }
}


function drawGroupedBar(err, json) {
    if(err) {
	return;
    }

    var departments = json['all_bodies'].map(function (d) { return d.values });
    var svg = d3.select('svg.groupedbar');

    var barchart = InteractiveBarChart(svg);

    function changeFunc() {
	var showZero = $('#show-zero').is(':checked');
	var log = $('input[name=log]:checked').val() == 'log';
	var field = $('#bar-value').val();
	barchart.drawBars(field, log, showZero, departments);
    }
    
    d3.select('#bar-value').on("change", changeFunc);
    d3.select('#show-zero').on("change", changeFunc);
    d3.selectAll('.radioLog').on("change", changeFunc);
    
    changeFunc();
}
$(function() { d3.json('index.json', drawGroupedBar); })
