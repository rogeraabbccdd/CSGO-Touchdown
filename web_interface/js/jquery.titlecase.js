/*
 * jQuery Title Case Plugin
 *
 * Copyright (c) 2010 Sean Flanagan <sean@redflannelgroup.com>
 * Based on David Gouch's To Title Case Javascript <http://individed.com/code/to-title-case/>
 * Itself based on John Gruber's Title Case Perl Script <http://daringfireball.net/2008/05/title_case, http://daringfireball.net/2008/08/title_case_update>
 *
 * To use, add .toTitleCase() to a selector. 
 * e.g. $("h1").toTitleCase();
 */
(function($) {
$.fn.toTitleCase = function() {
	$(this).each(function(){
	var headline = $(this).text();
	$(this).text(headline.replace(/([\w&`'‘’"“.@:\/\{\(\[<>_]+-? *)/g,function(match, pl, index, title){
		if (index > 0 && title.charAt(index - 2) !== ":" && match.search(/^(a(nd?|s|t)?|b(ut|y)|en|for|i[fn]|o[fnr]|t(he|o)|vs?\.?|via)[ \-]/i) > -1)
			return match.toLowerCase();
		if (title.substring(index - 1, index + 1).search(/['"_{(\[]/) > -1)
			return match.charAt(0) + match.charAt(1).toUpperCase() + match.substr(2);
		if (match.substr(1).search(/[A-Z]+|&|[\w]+[._][\w]+/) > -1 || title.substring(index - 1, index + 1).search(/[\])}]/) > -1)
			return match;
		return match.charAt(0).toUpperCase() + match.substr(1);
	}));
	});
};
})(jQuery);