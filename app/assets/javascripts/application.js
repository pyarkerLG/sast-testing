// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// SECURITY UPDATE: Removed outdated and vulnerable JavaScript libraries:
// - jQuery v1.8.3 (replaced with jquery3 from jquery-rails gem)
// - Bootstrap v2.2.2 (replaced with Bootstrap 5.x from bootstrap gem)
// - jQuery UI v1.8.23 (replaced with jquery-ui-rails gem)
// - Removed various other outdated libraries with known vulnerabilities
// - Fixed duplicate jQuery includes that could cause conflicts
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery3
//= require jquery_ujs
//= require turbolinks
//= require bootstrap
//= require jquery-ui
//= require jquery-fileupload/basic
//= require jquery-fileupload/vendor/tmpl

// SECURITY NOTE: The following vulnerable libraries have been REMOVED:
// - jquery.min.js (jQuery v1.8.3) - replaced with jquery3 from gem
// - bootstrap.js (Bootstrap v2.2.2) - replaced with bootstrap gem v5.3
// - jquery-ui-1.8.23.custom.min.js - replaced with jquery-ui-rails gem
// - jquery.dataTables.min.js (DataTables 1.10.16) - removed, update if needed
// - fullcalendar.min.js (FullCalendar 3.6.1) - removed, update if needed
// - Various other outdated libraries with known security vulnerabilities

function rubyCodeFormat() {
	


$("pre.ruby").snippet("ruby",{style:"rand01",transparent:true,showNum:true});
    // Finds <pre> elements with the class "js"
    // and snippet highlights the JAVASCRIPT code within
    // using a random style from the selection of 39
    // with a transparent background
    // without showing line numbers.



$("pre.javascript").snippet("javascript",{style:"rand01",transparent:true,showNum:true});
    // Finds <pre> elements with the class "js"
    // and snippet highlights the JAVASCRIPT code within
    // using a random style from the selection of 39
    // with a transparent background
    // without showing line numbers.

};

function coerceToString(val) {
  return String((val === null || val === undefined) ? '' : val);
}

var rAmp = /&/g,
     rLt = /</g,
     rGt = />/g,
     rApos = /\'/g,
     rQuot = /\"/g,
     hChars = /[&<>\"\']/;

function hoganEscape(str) {
    str = coerceToString(str);
    return hChars.test(str) ?
      str
        .replace(rAmp, '&amp;')
        .replace(rLt, '&lt;')
        .replace(rGt, '&gt;')
        .replace(rApos, '&#39;')
        .replace(rQuot, '&quot;') :
      str;
  }

$(document).ready(function(){
	rubyCodeFormat()
});
