package simplify {
	
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.utils.ByteArray;
	
	/**
	 * Загрузка файлов на сервер согласно http://ru.wikipedia.org/wiki/Multipart/form-data
	 *
	 * @example
	 * var uploader:URLUploader = new URLUploader();
	 * uploader.addFile(byteArray, "file", "avatar.png");
	 * uploader.addVariable("token", "48dcsa");
	 * uploader.upload("http://server.com/changeAvatar.php");
	 * //затем подписываемся на события как у стандартного URLLoader
	 * 
	 * 
	 * @author rzer & reraider
	 * @version 0.1
	 */
	public class URLUploader extends URLLoader {
		
		private var request:URLRequest;
		private var parts:Array = [];

		private static const BOUNDARY:String = "----------cH2gL6ei4Ef1gL6GI3Ij5EfGGf1Ef1";
        private static const CRLF:String = "\r\n";
        private static const HYPHENS:String = "--";
		
		public var haveFiles:Boolean = false;
		
		
		public function addFile(file:ByteArray, name:String = "file", fileName:String = "sample.obj"):void {
			
			haveFiles = true;
			
			var extension:String = fileName.split(".").pop();
			var contentType:String = getMimeType(extension);
	
			if (!contentType) {
				contentType = "application/octet-stream";
			}
			
			var data:ByteArray = new ByteArray();
            data.writeUTFBytes(HYPHENS + BOUNDARY + CRLF);
            data.writeUTFBytes("Content-Disposition: form-data; name=" + name + "; filename=" + fileName + CRLF);
            data.writeUTFBytes("Content-Type: " + contentType + CRLF + CRLF);
            data.writeBytes(file);
            data.writeUTFBytes(CRLF);
			
			parts.push(data);
        }
		
		public function addVariable(name:String, value:String):void {
			
			var data:ByteArray = new ByteArray();
            data.writeUTFBytes(HYPHENS + BOUNDARY + CRLF);
            data.writeUTFBytes("Content-Disposition: form-data; name=" + name + CRLF + CRLF);
            data.writeUTFBytes(value);
            data.writeUTFBytes(CRLF);
			
			parts.push(data);
			
		}
		
		public function upload(path:String):void {
			
			var bytes:ByteArray = new ByteArray();
			
			for (var i:int = 0; i < parts.length; i++ ) {
				var part:ByteArray = parts[i];
				bytes.writeBytes(part);
			}
			
            bytes.writeUTFBytes(HYPHENS + BOUNDARY + HYPHENS);
			
			request = new URLRequest();
			
			request.url = path;
			request.requestHeaders.push(new URLRequestHeader("Content-type", "multipart/form-data; boundary=" + BOUNDARY));
			dataFormat	= URLLoaderDataFormat.BINARY;
			request.method = URLRequestMethod.POST;
			request.data = bytes;
			
			this.load(request);
		}
		
		//////////////////////////// STATIC
		
		private static var types:Array = 
			[["application/andrew-inset","ez"],
			["application/atom+xml","atom"],
			["application/mac-binhex40","hqx"],
			["application/mac-compactpro","cpt"],
			["application/mathml+xml","mathml"],
			["application/msword","doc"],
			["application/octet-stream","bin","dms","lha","lzh","exe","class","so","dll","dmg"],
			["application/oda","oda"],
			["application/ogg","ogg"],
			["application/pdf","pdf"],
			["application/postscript","ai","eps","ps"],
			["application/rdf+xml","rdf"],
			["application/smil","smi","smil"],
			["application/srgs","gram"],
			["application/srgs+xml","grxml"],
			["application/vnd.adobe.apollo-application-installer-package+zip","air"],
			["application/vnd.mif","mif"],
			["application/vnd.mozilla.xul+xml","xul"],
			["application/vnd.ms-excel","xls"],
			["application/vnd.ms-powerpoint","ppt"],
			["application/vnd.rn-realmedia","rm"],
			["application/vnd.wap.wbxml","wbxml"],
			["application/vnd.wap.wmlc","wmlc"],
			["application/vnd.wap.wmlscriptc","wmlsc"],
			["application/voicexml+xml","vxml"],
			["application/x-bcpio","bcpio"],
			["application/x-cdlink","vcd"],
			["application/x-chess-pgn","pgn"],
			["application/x-cpio","cpio"],
			["application/x-csh","csh"],
			["application/x-director","dcr","dir","dxr"],
			["application/x-dvi","dvi"],
			["application/x-futuresplash","spl"],
			["application/x-gtar","gtar"],
			["application/x-hdf","hdf"],
			["application/x-javascript","js"],
			["application/x-koan","skp","skd","skt","skm"],
			["application/x-latex","latex"],
			["application/x-netcdf","nc","cdf"],
			["application/x-sh","sh"],
			["application/x-shar","shar"],
			["application/x-shockwave-flash","swf"],
			["application/x-stuffit","sit"],
			["application/x-sv4cpio","sv4cpio"],
			["application/x-sv4crc","sv4crc"],
			["application/x-tar","tar"],
			["application/x-tcl","tcl"],
			["application/x-tex","tex"],
			["application/x-texinfo","texinfo","texi"],
			["application/x-troff","t","tr","roff"],
			["application/x-troff-man","man"],
			["application/x-troff-me","me"],
			["application/x-troff-ms","ms"],
			["application/x-ustar","ustar"],
			["application/x-wais-source","src"],
			["application/xhtml+xml","xhtml","xht"],
			["application/xml","xml","xsl"],
			["application/xml-dtd","dtd"],
			["application/xslt+xml","xslt"],
			["application/zip","zip"],
			["audio/basic","au","snd"],
			["audio/midi","mid","midi","kar"],
			["audio/mp4","f4a"],
			["audio/mp4","f4b"],
			["audio/mpeg","mp3","mpga","mp2"],
			["audio/x-aiff","aif","aiff","aifc"],
			["audio/x-mpegurl","m3u"],
			["audio/x-pn-realaudio","ram","ra"],
			["audio/x-wav","wav"],
			["chemical/x-pdb","pdb"],
			["chemical/x-xyz","xyz"],
			["image/bmp","bmp"],
			["image/cgm","cgm"],
			["image/gif","gif"],
			["image/ief","ief"],
			["image/jpeg","jpg","jpeg","jpe"],
			["image/png","png"],
			["image/svg+xml","svg"],
			["image/tiff","tiff","tif"],
			["image/vnd.djvu","djvu","djv"],
			["image/vnd.wap.wbmp","wbmp"],
			["image/x-cmu-raster","ras"],
			["image/x-icon","ico"],
			["image/x-portable-anymap","pnm"],
			["image/x-portable-bitmap","pbm"],
			["image/x-portable-graymap","pgm"],
			["image/x-portable-pixmap","ppm"],
			["image/x-rgb","rgb"],
			["image/x-xbitmap","xbm"],
			["image/x-xpixmap","xpm"],
			["image/x-xwindowdump","xwd"],
			["model/iges","igs","iges"],
			["model/mesh","msh","mesh","silo"],
			["model/vrml","wrl","vrml"],
			["text/calendar","ics","ifb"],
			["text/css","css"],
			["text/html","html","htm"],
			["text/plain","txt","asc"],
			["text/richtext","rtx"],
			["text/rtf","rtf"],
			["text/sgml","sgml","sgm"],
			["text/tab-separated-values","tsv"],
			["text/vnd.wap.wml","wml"],
			["text/vnd.wap.wmlscript","wmls"],
			["text/x-setext","etx"],
			["video/mp4","f4v"],
			["video/mp4","f4p"],			
			["video/mpeg","mpg","mpeg","mpe"],
			["video/quicktime","mov","qt"],
			["video/vnd.mpegurl","m4u","mxu"],
			["video/x-flv","flv"],
			["video/x-msvideo","avi"],
			["video/x-sgi-movie","movie"],
			["x-conference/x-cooltalk", "ice"]];
			
		/**
		 * Возвращает mymetype в зависимости от расширения
		 */
		public static function getMimeType(extension:String):String
		{
			extension = extension.toLocaleLowerCase();
			for each (var a:Array in types)
			{
				for each (var b:String in a)
				{
					if (b == extension)
					{
						return a[0];
					}
				}
			}
			return null;
		}

		/**
		 *	Возвращает наиболее используемое расширение файла в зависимости от mimeType
		 */
		public static function getExtension(mimetype:String):String
		{
			mimetype = mimetype.toLocaleLowerCase();
			for each (var a:Array in types)
			{
				if (a[0] == mimetype)
				{
					return a[1];
				}
			}
			return null;
		}

		/**
		 * Добавляем mimetype в карту
		 */
		public static function addMimeType(mimetype:String, extensions:Array):void
		{
			var newType:Array = [mimetype];
			for each (var a:String in extensions)
			{
				newType.push(a);
			}
			types.push(newType);
		}
		
	}

}