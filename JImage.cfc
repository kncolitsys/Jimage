<cfcomponent 
	displayname="JImage" 
    output="no" 
    hint="" >
    
    <!--- Return reference to this Component --->
    <cffunction name="init" returntype="JImage" output="no" access="public"
    	hint="Returns an initialized JImage instance.">
    	
        <!--- Returns this reference --->
    	<cfreturn this>
    </cffunction>
    
    <!--- 
	Function: resize
	Description: Resizes the given image and stores as another file without modifying the source
	Paramerter:
		fileIn:(required) to specify the source image file to read from.
		fileOut:(required) to specify the target image file to write.
		width:(required) to specify the width of destination image file. 
		height:(required) to specify the height of destination image file.
			If you specify a width with a non-zero postitive integer and height with "" than the height will be calculated using the aspect ratio of the original image.
			And alternatively if you specify a width with "" and height with a non-zero postitive integer than the width will be calculated using the aspect ratio of the original image.
	 --->    
    <cffunction name="resize" output="no" returntype="void">
    	<!--- Required Parameters --->
    	<cfargument name="fileIn" type="string" required="yes">
        <cfargument name="fileOut" type="string" required="yes">
        <cfargument name="width" default="">
        <cfargument name="height" default="">
        
        <!---  --->
        <cftry>
			<cfset JBufferedImage = #generateBufferedImage(ARGUMENTS.fileIn)#>
			<cfset destinationFile = #ARGUMENTS.fileOut#>
			
			<cfif #fixToZero(width)# GT 0 AND #fixToZero(height)# GT 0>
            	<cfset MaintainAspectRatio = "no">
                
            <cfelseif #fixToZero(width)# GT 0 XOR #fixToZero(height)# GT 0>
				<cfset MaintainAspectRatio = "yes">
                
			<cfelse>
				<cfthrow type="JImage" message="Invalid Dimensions!" detail="One or both of the dimensions (width and height) must be non-zero positive integer.">
			</cfif>
            
            
            <cfset dimension = StructNew()>
			<cfif #MaintainAspectRatio# EQ "yes">
               <cfif #fixToZero(width)# GT 0 >
                    <cfset aspect = #Evaluate(ARGUMENTS.width / JBufferedImage.getWidth())#>
                    <cfset dimension.width = #ARGUMENTS.width#>
                    <cfset dimension.height = #Evaluate(aspect * JBufferedImage.getHeight())#>
                <cfelse>
                    <cfset aspect = #Evaluate(ARGUMENTS.height / JBufferedImage.getHeight())#>
                    <cfset dimension.width = #Evaluate(aspect * JBufferedImage.getWidth())#>
                    <cfset dimension.height = #ARGUMENTS.height#>
                </cfif>
            <cfelse>
                <cfset dimension.width = ARGUMENTS.width>
                <cfset dimension.height = ARGUMENTS.height>
            </cfif>
            
            <cfset #resizeBufferedImage(bufferedImage = #JBufferedImage#, 
                                        destinationFilePath = #destinationFile#, 
                                        dimension = #dimension#)# />
            
            
            
		<cfcatch type="any">
			<cfthrow type="JImage" message="#CFCATCH.Message#" detail="#CFCATCH.Detail#">
		</cfcatch>
		</cftry>        
    </cffunction>
    
    
    <!--- 
	Function: resizeAll
	Description: Resizes the given image and stores as another file without modifying the source
	Paramerter:
		fileIn:(required) to specify the source image file to read from.
		filesArray:(required) to specify an array of target image files(structs) with keys [targetPath,width,height]
		
	 --->    
    <cffunction name="resizeAll" output="no" returntype="void">
    	<!--- Required Parameters --->
    	<cfargument name="fileIn" type="string" required="yes">
        <cfargument name="filesArray" type="array" required="yes">
        
        <!---  --->
        <cftry>
			<cfset JBufferedImage = #generateBufferedImage(ARGUMENTS.fileIn)#>
			
            <cfloop from="1" to="#ArrayLen(filesArray)#" index="fileInd">
				<cfset aHeight = #filesArray[fileInd].height#>
                <cfset aWidth = #filesArray[fileInd].width#>
                <cfset aDestFile = #filesArray[fileInd].targetPath#>
            	
                <cfif #fixToZero(aWidth)# GT 0 AND #fixToZero(aHeight)# GT 0>
					<cfset MaintainAspectRatio = "no">
                    
                <cfelseif #fixToZero(aWidth)# GT 0 XOR #fixToZero(aHeight)# GT 0>
                    <cfset MaintainAspectRatio = "yes">
                    
                <cfelse>
                    <cfthrow type="JImage" message="Invalid Dimensions!" detail="One or both of the dimensions (width and height) must be non-zero positive integer. Problem at array index #fileInd#.">
                </cfif>
                
                
				<cfset dimension = StructNew()>
                <cfif #MaintainAspectRatio# EQ "yes">
                    <cfif #fixToZero(aWidth)# GT 0 >
                        <cfset aspect = #Evaluate(aWidth / JBufferedImage.getWidth())#>
                        <cfset dimension.width = #aWidth#>
                        <cfset dimension.height = #Evaluate(aspect * JBufferedImage.getHeight())#>
                    <cfelse>
                        <cfset aspect = #Evaluate(aHeight / JBufferedImage.getHeight())#>
                        <cfset dimension.width = #Evaluate(aspect * JBufferedImage.getWidth())#>
                        <cfset dimension.height = #aHeight#>
                    </cfif>
                <cfelse>
                    <cfset dimension.width = aWidth>
                    <cfset dimension.height = aHeight>
                </cfif>
                
                <cfset #resizeBufferedImage(bufferedImage = #JBufferedImage#, 
                                            destinationFilePath = #aDestFile#, 
                                            dimension = #dimension#)# />

        	</cfloop>
		<cfcatch type="any">
			<cfthrow type="JImage" message="#CFCATCH.Message#" detail="#CFCATCH.Detail#">
		</cfcatch>
		</cftry>        
    </cffunction>
       
    
    <!--- 
	Function: generateBufferedImage
	Description: Returns java.awt.image.BufferedImage object of a given image file.
				 BufferedImage gives the functionality to attain almost all of the properties of an image.
	 --->
    <cffunction name="generateBufferedImage">
    	<cfargument name="imagePath" type="string" required="yes" 
        	hint="generateBufferedImage function requires a parameter of type String, that should contain a source image file path.">
        
		<cftry>
			<cfset imageFile = #CreateObject("java", "java.io.File").init(JavaCast("string", ARGUMENTS.imagePath))#>        
			<cfset imageStreamIn = #CreateObject("java", "javax.imageio.stream.FileImageInputStream").init(imageFile)#>
			<cfset imageIO = #CreateObject("java", "javax.imageio.ImageIO")#>
			
			<cfreturn imageIO.read(imageStreamIn)>        
			
		<cfcatch type="any">
			<cfthrow type="JImage" message="#CFCATCH.Message#" detail="#CFCATCH.Detail#">
		</cfcatch>
		</cftry>        
    </cffunction>
    
    
    
    <cffunction name="resizeBufferedImage">
    	<cfargument name="bufferedImage" required="yes">
        <cfargument name="destinationFilePath" required="yes">
        <cfargument name="dimension" default="">
        
		<cftry>
			
			<!--- set dimensions for target image file --->
			<!--- set dimensions as provided --->
			<cfif #IsStruct(ARGUMENTS.dimension)#>
				<cfset tWidth = ARGUMENTS.dimension.width>
				<cfset tHeight = ARGUMENTS.dimension.height>
				
			<!--- set dimensions as of the original image. Practically this case should not happen as the function's primary purpose is to resize the original image. --->
			<cfelse>
				<cfset tWidth = #ARGUMENTS.bufferedImage.getWidth()#>
				<cfset tHeight = #ARGUMENTS.bufferedImage.getHeight()#>
				
			</cfif>
			
			<cfset xScale = #Evaluate( tWidth/ARGUMENTS.bufferedImage.getWidth() )# >
			<cfset yScale = #Evaluate( tHeight/ARGUMENTS.bufferedImage.getHeight() )# >
			
			
			<!--- Requird Java objects initialization --->
			<cfset JImageIO = CreateObject("java", "javax.imageio.ImageIO") >
			<cfset JAffineTransform = CreateObject("java", "java.awt.geom.AffineTransform") >
			<cfset JAffineTransformOp = CreateObject("java", "java.awt.image.AffineTransformOp") >
			<cfset JRenderingHints = CreateObject("java", "java.awt.RenderingHints") >
			<cfset JFile = CreateObject("java", "java.io.File") >
			<cfset JContainer = CreateObject("java", "java.awt.Container") >
			
			<cfset #JContainer.init()# />
			
			<cfset #JAffineTransform.init()# />
			<cfset #JAffineTransform.scale(JavaCast("double", xScale), JavaCast("double", yScale))# />
			
			<cfset #JRenderingHints.init(JRenderingHints.KEY_INTERPOLATION, JRenderingHints.VALUE_INTERPOLATION_BICUBIC)# />
			<cfset #JRenderingHints.put(JRenderingHints.KEY_RENDERING, JRenderingHints.VALUE_RENDER_QUALITY)# />
			<cfset #JRenderingHints.put(JRenderingHints.KEY_COLOR_RENDERING, JRenderingHints.VALUE_COLOR_RENDER_QUALITY)# />
			<cfset #JRenderingHints.put(JRenderingHints.KEY_TEXT_ANTIALIASING, JRenderingHints.VALUE_TEXT_ANTIALIAS_ON)# />
			
			<cfset #JAffineTransformOp.init(JAffineTransform, JRenderingHints)# />
			<cfset JDestinationImage = #JAffineTransformOp.createCompatibleDestImage(ARGUMENTS.bufferedImage, ARGUMENTS.bufferedImage.getColorModel())#>
			
			<cfset JGraphics = #JDestinationImage.createGraphics()#>
			<cfset #JGraphics.drawImage(ARGUMENTS.bufferedImage, JAffineTransform, JContainer)# />
			<cfset #JGraphics.dispose()# />
			
			<cfset #JFile.init(ARGUMENTS.destinationFilePath)# />
			<cfset #JImageIO.write(JDestinationImage, getExtension(ARGUMENTS.destinationFilePath), JFile)# />
		
		<cfcatch type="any">
			<cfthrow type="JImage" message="#CFCATCH.Message#" detail="#CFCATCH.Detail#">
		</cfcatch>
		</cftry>        	
    </cffunction>
    
	<cffunction name="getExtension">
		<cfargument  name="file">
		
		<cfreturn #ListGetAt(file,ListLen(file,"."),".")#>
	</cffunction>
    
    <cffunction name="fixToZero" returntype="numeric">
    	<cfargument name="number">

        <cfif NOT #IsNumeric(number)#>
        	<cfset number = 0>
        </cfif>
        
        <cfreturn number>
    </cffunction>
    
    
</cfcomponent>