function deptColor(d) {
    if(typeof(d) != "string") {
	return "none";
    }
    dept = d.replace(",", "");
    if(dept == "Treasury") {
	return "#af292e";
    }
    else if(dept == "Cabinet Office") {
	return  "#0078ba";
    }
    else if(dept == "Department for Education") {
	return  "#003a69";
    }
    else if(dept == "Department for Transport") {
	return  "#006c56";
    }
    else if(dept == "Home Office") {
	return  "#9325b2";
    }
    else if(dept == "Department of Health") {
	return  "#00ad93";
    }
    else if(dept == "Ministry of Justice") {
	return  "#231f20";
    }
    else if(dept == "Ministry of Defence") {
	return  "#4d2942";
    }
    else if(dept == "Foreign and Commonwealth Office") {
	return  "#003e74";
    }
    else if(dept == "Department for Communities and Local Government") {
	return  "#00857e";
    }
    else if(dept == "Department for Energy and Climate Change") {
	return  "#009ddb";
    }
    else if(dept == "Department of Energy and Climate Change") {
	return  "#009ddb";
    }
    else if(dept == "Department for Culture Media and Sport") {
	return  "#d40072";
    }
    else if(dept == "Department for Environment Food and Rural Affairs") {
	return  "#898700";
    }
    else if(dept == "Department for Work and Pensions") {
	return  "#00beb7";
    }
    else if(dept == "Department for Business Innovation and Skills") {
	return  "#003479";
    }
    else if(dept == "Department for International Development") {
	return  "#002878";
    }
    else if(dept == "Government Equalities Office") {
	return  "#9325b2";
    }
    else if(dept == "Attorney General's Office") {
	return  "#9f1888";
    }
    else if(dept == "Scotland Office") {
	return  "#002663";
    }
    else if(dept == "Wales Office") {
	return  "#a33038";
    } else {
	return "#0076c0";//Some departments we might not know a colour for ("Northern Ireland Office"), so use HM Government (because that isn't incorrect)
    }
}

$(function() {
    var svg = d3.select('svg.areachart')
    var box = svg[0][0].viewBox.baseVal;
    var width = box.width;
    var height = box.height;

    var data = {children : $('#fundingtable tr.dataline')
		.map(function() { return {dataset: this.dataset,
					  name: this.dataset.name,
					  funding: parseInt(this.dataset.funding),
					  color: deptColor(this.dataset.department)} })
		.filter(function(index, value) { return value.funding > 10000000})};


    var treemapwidth = width - 400;
    var treemap = d3.layout.treemap()
	.sort(function(a, b) { return a.funding - b.funding })
	.size([treemapwidth, height])
	.round(true)
	.value(function(d) { return d.funding; });

    var nodes = treemap(data);

    var group1 = svg.append("g")
    
    group1.selectAll("rect")
	.data(nodes)
	.enter()
	.append("rect")
    	.attr("x", function(d) { return d.x } )
	.attr("y", function(d) { return d.y } )
	.attr("width", function(d) { return d.dx } )
	.attr("height", function(d) { return d.dy } )
	.style("fill", function(d) { return d.color; })
	.style("stroke", "white");

    var departments = $('th.departmentheader');
    var group2 = svg.append("g");

    var scale = d3.scale.linear().domain([0, departments.length]).range([0, height]);

    group2.selectAll("g")
	.data(departments)
	.enter()
	.append("text")
	.attr("x", treemapwidth + 25)
	.attr("y", function(d, i) { return scale(i) + 12; })
	.text(function(d) { return d.dataset.name });
    group2.selectAll("g")
	.data(departments)
	.enter()
	.append("rect")
	.attr("x", treemapwidth + 10)
	.attr("y", function(d, i) { return scale(i) + 1; })
	.attr("width", 12)
    	.attr("height", 12)
	.style("stroke", "black")
	.style("fill", function(d) { return deptColor(d.dataset.name); })
	.text(function(d) { return d.dataset.name })
});
