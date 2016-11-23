

<cfif IsDefined("form.imagefile")>
	<cfparam name="form.width" default="100">
	<cfparam name="form.height" default="75">
	<cfparam name="form.type" default="resize">
	
	<cfoutput>
	<cffile action="upload" filefield="imagefile" destination="#ExpandPath("./")#" nameconflict="overwrite" accept="image/jpeg,image/gif,image/png,image/x-png,image/jpg,image/pjpeg,image/bmp">
    <cfset destfileext = #CFFILE.serverFileExt#>
    

	
	<cfif #Form.Action# EQ "Resize">
        <cf_jimage 
            Action = "Resize"
            Source = "#ExpandPath(cffile.serverFile)#"
            Destination = "#ExpandPath('./upload/#cffile.serverFile#')#"
            Width = "#Form.Width#"
            Height = "#Form.Height#"
            
            />
        <cfif #cf_jimage.Error# EQ 0>
            <h2>Resized Image</h2>
            <img src="upload/#cffile.serverFile#" />
        <cfelse>
        <font color="##FF0000">
            
			#cf_jimage.Desc#<br />
            #cf_jimage.ErrMessage#<br />
            #cf_jimage.ErrDetail#<br />
        </font>
        </cfif>
        
    <cfelseif #Form.Action# EQ "ResizeAll">
    	<cfset sourceFile = #ExpandPath(CFFILE.serverFile)#>
        <cfset destFileName = #CFFILE.serverDirectory# & "\" & #CFFILE.serverFileName#>
        
        <cfset targetFileArray = #ArrayNew(1)#>
                
		<cfset targetFileArray[1] = #StructNew()#>
        <cfset targetFileArray[1].targetPath = #destFileName# & "-big." & #CFFILE.serverFileExt#>
        <cfset targetFileArray[1].displayPath = #CFFILE.serverFileName# & "-big." & #CFFILE.serverFileExt#>
		<cfset targetFileArray[1].width = "#Form.width#">
        <cfset targetFileArray[1].height = "#Form.height#">        
        
        
        <cfset targetFileArray[2] = #StructNew()#>
        <cfset targetFileArray[2].targetPath = #destFileName# & "-med." & #CFFILE.serverFileExt#>
        <cfset targetFileArray[2].displayPath = #CFFILE.serverFileName# & "-med." & #CFFILE.serverFileExt#>
		<cfif #IsNumeric(Form.width)# AND #Form.width# GT 0>
	        <cfset targetFileArray[2].width = #Int(Evaluate(Form.width/2))#>
        <cfelse>
        	<cfset targetFileArray[2].width = "">
        </cfif>
        <cfif #IsNumeric(Form.height)# AND #Form.height# GT 0>
	        <cfset targetFileArray[2].height = #Int(Evaluate(Form.height/2))#>
        <cfelse>
        	<cfset targetFileArray[2].height = "">
        </cfif>
        
        
        
        <cfset targetFileArray[3] = #StructNew()#>
        <cfset targetFileArray[3].targetPath = #destFileName# & "-small." & #CFFILE.serverFileExt#>
        <cfset targetFileArray[3].displayPath = #CFFILE.serverFileName# & "-small." & #CFFILE.serverFileExt#>
		<cfif #IsNumeric(Form.width)# AND #Form.width# GT 0>
	        <cfset targetFileArray[3].width = #Int(Evaluate(Form.width/2/2))#>
        <cfelse>
        	<cfset targetFileArray[3].width = "">
        </cfif>
        <cfif #IsNumeric(Form.height)# AND #Form.height# GT 0>
	        <cfset targetFileArray[3].height = #Int(Evaluate(Form.height/2/2))#>
        <cfelse>
        	<cfset targetFileArray[3].height = "">
        </cfif>
        
        
        
    	<cf_jimage 
            Action = "ResizeAll"
            Source = #sourceFile#
            Destination = #targetFileArray#
            
            />
        <cfif #cf_jimage.Error# EQ 0>
            <b>Results</b><br />
            <cfloop from="1" to="#ArrayLen(targetFileArray)#" index="Ind">
	            <img src="#targetFileArray[Ind].displayPath#" /> =
            </cfloop>
        <cfelse>
        	<cfdump var="#cf_jimage.CATCH#">
        <font color="##FF0000">
            #cf_jimage.Desc#<br />
            #cf_jimage.ErrMessage#<br />
            #cf_jimage.ErrDetail#<br />
        </font>
        </cfif>
    </cfif>
	
	</cfoutput>
</cfif>

<html>
<head>
	<title>J Image Resize Example</title>	
</head>
<cfoutput>
</cfoutput>
<form action="testimage.cfm" method="post" enctype="multipart/form-data">
	<input type="file" name="imagefile" />
	<br />
    Action: <select name="Action">
                <option value="Resize">Resize</option>
                <option value="ResizeAll">Resize All</option>
            </select>
	<br />
		Width: <input type="text" name="width" size="5" value="" />
		Height: <input type="text" name="height" size="5" value="" /><br />
	<br /><br />
	<input name="resize" type="submit" value="Resize Image" />

</form>
