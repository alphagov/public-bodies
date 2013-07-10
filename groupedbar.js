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
    var heightScale = d3.scale.linear().domain([0, 6846711000]).range([0, height]);
    
    $.
$(function() { d3.json('index.json', drawGroupedBar); })
