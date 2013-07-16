(function ($) {
    $.fn.tfilter = function(val) {
	this.filter('table')
	    .children('tbody')
	    .children('tr')
	    .show()
	    .filter(function(i, tr) { return !(new RegExp(val, 'ig').test(tr.dataset.name)) } )
	    .hide()
	return this;
    }
}(jQuery))
