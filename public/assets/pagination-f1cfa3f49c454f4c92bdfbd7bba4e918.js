$(function(){$(document).on("click",".pagination a",function(){return $(".pagination").html("Loading..."),$.get(this.href,null,null,"script"),!1})});