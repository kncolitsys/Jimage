<!--- 
Usage:
Create a single image with resized dimensions
<cf_jimage
   required 
   action = "resize"
		 source = "source image file path to be resized"
		 destination = "target image file path to be stored with resized dimensions"
		 width = "width in pixels. A non-zero positive integer"
		 height = "height in pixels. A non-zero positive integer"
				If you specify a width with a non-zero postitive integer and height with "" than the height will be calculated using the aspect ratio of the original image.
				And alternatively if you specify a width with "" and height with a non-zero postitive integer than the width will be calculated using the aspect ratio of the original image.


Create a single image with resized dimensions
<cf_jimage
   required 
   action = "ResizeAll"
		 source = "source image file path to be resized"
		 destination = "an array of structs with following keys"
			 targetPath = "target image file path to be stored with resized dimensions"
			 width = "width in pixels. A non-zero positive integer"
			 height = "height in pixels. A non-zero positive integer"
						If you specify a width with a non-zero postitive integer and height with "" than the height will be calculated using the aspect ratio of the original image.
						And alternatively if you specify a width with "" and height with a non-zero postitive integer than the width will be calculated using the aspect ratio of the original image.
	
    
--->

<CFHEADER NAME="Expires" VALUE="-1">
<cfoutput>
<!--- Attributes --->
<cftry>
	<cfparam name="ATTRIBUTES.action" default="">    
	<cfparam name="ATTRIBUTES.source" default="">
	<cfparam name="ATTRIBUTES.destination" default="">
	<cfparam name="ATTRIBUTES.width" default="">
	<cfparam name="ATTRIBUTES.height" default="">
	

	<!--- Returns Structure Response--->
	<cfset CALLER.cf_jimage = StructNew()>
	<cfset CALLER.cf_jimage.ERROR = "0">
	
    <!--- Structure LOCAL, to Store content which is used locally to this tag--->
    <cfset LOCAL = StructNew()>
    <cfset LOCAL.CONST_ALLOWED_ACTIONS = "RESIZE|RESIZEALL">
    
    
    <!--- Verify Parameters --->
    <cfif #ATTRIBUTES.Action# EQ "">
		<cfthrow type="any" message="A required parameter is missing." detail="Required attribute 'Action' is missing.">
	<cfelseif #ListFindNoCase(LOCAL.CONST_ALLOWED_ACTIONS, ATTRIBUTES.Action, "|")# EQ 0>
		<cfthrow type="any" message="Invalid Value!" detail="Invalid value provided in attribute 'Action'. Allowed values are [#LOCAL.CONST_ALLOWED_ACTIONS#].">
	</cfif>
    
	<cfif #ATTRIBUTES.source# EQ "">
		<cfthrow type="any" message="A required parameter is missing." detail="Required attribute 'source' is missing.">
	<cfelseif NOT #FileExists(ATTRIBUTES.source)#>
		<cfthrow type="any" message="File doesn't exists." detail="Image File provided in 'source' is not found. Please check that you provided a correct path to the file.">
	</cfif>
	
    <cfif #ATTRIBUTES.Action# EQ "Resize">
    	<cfif #ATTRIBUTES.destination# EQ "">
            <cfthrow type="any" message="A required parameter is missing." detail="Required attribute 'destination' is missing.">
        </cfif>
        
		<cfset DestDir  = #ListDeleteAt(ATTRIBUTES.destination, ListLen(ATTRIBUTES.destination,"\"),"\")#>
        <cfif NOT #DirectoryExists(DestDir)#>
            <cfthrow type="any" message="Directory doesn't exists." detail="Target directory, where you want to create a target image file, doesn't exist. Make sure the directory path, where you want to create a new image file, does exist.">
        </cfif>
        
        <cfif #fixToZero(width)# LE 0 AND #fixToZero(height)# LE 0>
	        <cfthrow type="any" message="Invalid Dimensions!" detail="One or both of the dimensions (width and height) must be non-zero positive integer.">
        </cfif>
        
    <cfelseif #ATTRIBUTES.Action# EQ "ResizeAll">
    	<cfif NOT #IsArray(ATTRIBUTES.destination)#>
        	<cfthrow type="any" message="Invalid Content!" detail="If 'Action' is set to 'ResizeAll', then 'destination' must be an array of file paths and dimensions.">
        </cfif>
        
        <cfloop from="1" to="#ArrayLen(ATTRIBUTES.destination)#" index="LOCAL.Ind">
        	<cfset LOCAL.DestDir  = #ListDeleteAt(ATTRIBUTES.destination[LOCAL.Ind].targetPath, ListLen(ATTRIBUTES.destination[LOCAL.Ind].targetPath,"\"),"\")#>
			<cfif NOT #DirectoryExists(LOCAL.DestDir)#>
                <cfthrow type="any" message="Directory doesn't exists." detail="Target directory in array index #LOCAL.Ind#, where you want to create a target image file, doesn't exist. Make sure the directory path in targetPath of struct destination[#LOCAL.Ind#] does exist.">
            </cfif>
            
            <cfif #fixToZero(ATTRIBUTES.destination[LOCAL.Ind].width)# LE 0 AND #fixToZero(ATTRIBUTES.destination[LOCAL.Ind].height)# LE 0>
                <cfthrow type="any" message="Invalid Dimensions!" detail="both of the dimensions (height and width) at array index #LOCAL.Ind# are zero or negative. One or both of the dimensions (width and height) must be non-zero positive integers.">
            </cfif>
                
        </cfloop>
        
    </cfif>
	
	
    <!---  --->
    
	<cfset LOCAL.objimage = CreateObject("component","JImage").Init()>	
    <cfif #ATTRIBUTES.Action# EQ "RESIZE">
		<cfset LOCAL.objimage.resize(
					fileIn = #ATTRIBUTES.source#, 
					fileOut = #ATTRIBUTES.destination#,
					height = #ATTRIBUTES.height#,
					width = #ATTRIBUTES.width#
				) > 
                        
	<cfelseif #ATTRIBUTES.Action# EQ "RESIZEALL">
    	<cfset LOCAL.objimage.resizeAll(
					fileIn = #ATTRIBUTES.source#, 
					filesArray = #ATTRIBUTES.destination#
				) > 
                
	</cfif>
					
					
<cfcatch type="JImage">
	<cfset CALLER.cf_jimage.ERROR = "1">
	<cfset CALLER.cf_jimage.Desc = "There was an error while manipulating image.">
	<cfset CALLER.cf_jimage.ErrDetail = #CFCATCH.Detail#>
	<cfset CALLER.cf_jimage.ErrMessage = #CFCATCH.Message#>
    <cfset CALLER.cf_jimage.CATCH = #CFCATCH#>
</cfcatch>
<cfcatch type="any">
	<cfset CALLER.cf_jimage.ERROR = "1">
	<cfset CALLER.cf_jimage.Desc = "There was an error while executing the image tag.">
	<cfset CALLER.cf_jimage.ErrDetail = #CFCATCH.Detail#>
	<cfset CALLER.cf_jimage.ErrMessage = #CFCATCH.Message#>
    <cfset CALLER.cf_jimage.CATCH = #CFCATCH#>
</cfcatch>
</cftry>

<cffunction name="fixToZero" returntype="numeric">
    <cfargument name="number">

    <cfif NOT #IsNumeric(number)#>
        <cfset number = 0>
    </cfif>
    
    <cfreturn number>
</cffunction>
</cfoutput>