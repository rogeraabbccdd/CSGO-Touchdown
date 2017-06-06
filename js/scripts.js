
function showmodal(page){
	document.getElementById("modal").innerHTML = "<center><img src='images/modalloading.gif' style='valign:center;align:center'></center>";
	/*
	//SHOWMODAL
	
	$("#modal").modal(
				{
					//autoResize:true,
					minHeight: 300,
					minWidth: 298,
					escClose: true,
					overlayClose: true,
					modal: true,
					overlayCss: {backgroundColor:"black"},
					containerCss:{
						backgroundColor:"#a4a4a4",
						borderColor:"#fff",
						paddingTop: "10px",
						paddingBottom: "10px",
						paddingLeft: "10px",
						paddingRight: "10px",
					}
					
				}
			);*/
	
		$.blockUI({ message: $('#modal') , css: { height: '94%', width: 'auto',backgroundColor:"#a4a4a4",
						top: "1%",
						left: "5%",
						paddingTop: "10px",
						paddingBottom: "10px",
						paddingLeft: "10px",
						paddingRight: "10px", marginBottom: "auto", marginLeft: "auto", marginRight: "auto", marginTop: "auto",borderColor: '#fff', borderWidths: '1px'  } } ); 
		
		$('.blockOverlay').attr('title','Click to unblock').click($.unblockUI);
	
	$.get(page,"",
		function(data){
			//alert(data);
		
$(".blockMsg").animate({ height: 'toggle', width: 'toggle'},'slow',function(){
				$("#modal").html(data);$(".blockMsg").animate({ height: 'toggle', width: 'toggle'},'slow',make_oddeven(1));
				});
		//	resizemodal();
		
					//Specify Even and Odd Selectors
			
			
		}
	);

}


function make_oddeven(a){
	
	$(".normaltable tr:even").css("background-color","rgb(70, 70, 70)");
	$(".normaltable tr:odd").css("background-color","rgb(98, 98, 98)");
	
}

 
	document.onkeydown = function(e){ 
	  if (e == null) { // ie 
		keycode = event.keyCode; 
	  } else { // mozilla 
		keycode = e.which; 
	  } 
	  if(keycode == 27){ // escape, close box 
		$(".blockMsg").animate({ height: 'toggle', width: 'toggle'},'slow',function(){
						$.unblockUI();
					});
	  } 
	 }
	 $('a').toTitleCase();

function resizemodal(){
	$("#simplemodal-container").css("height","auto").css("width","auto");
		
}	