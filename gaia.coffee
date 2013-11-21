fs=require "fs"

mode=process.argv[2]

if mode == "new"

	if process.argv.length < 4
		console.log "usage: gaia new <directory> (<url>)"
		process.exit 0

	dir=process.argv[3]

	if process.argv.length == 5
		htaccess=""
		url=process.argv[4]
		url=url.replace(/\/+/,"")
		newStr="RewriteRule\t^"+url+"(.*)$\t"+dir+"/$1\t[L,QSA]\n"
		if fs.existsSync ".htaccess"
			flag=false
			stacked=""
			fs.readFileSync(".htaccess").toString().split("\n").forEach (line) ->
				if flag < 2
					if line == "#Gaia Condition Start"
						flag=1
						htaccess+=line+"\n"
					else if line == "#Gaia Condition End"
						stacked+=line+"\n"
						htaccess+=newStr+stacked
						flag=2
					else
						if flag == 0
							htaccess+=line+"\n"
						else if flag == 1
							stacked+=line+"\n"
			fs.writeFileSync(".htaccess",htaccess.toString())
		else
			htaccess="#Created by FHC-Gaia\n"
			htaccess+="AddDefaultCharset UTF-8\n"
			htaccess+="RewriteEngine On\n"
			htaccess+="#---------------------------------------------------|\n"
			htaccess+="RewriteCond\t%{REQUEST_FILENAME}\t-f\n"
			htaccess+="RewriteRule\t.+\t-\t[L]\n"
			htaccess+="RewriteCond\t%{REQUEST_URI}\t!^$\n"
			htaccess+="#---------------------------------------------------|\n"
			htaccess+="#Gaia Condition Start\n"
			htaccess+=newStr
			htaccess+="#Gaia Condition End\n"
			fs.writeFileSync(".htaccess",htaccess.toString())
	exec=require("child_process").exec
	exec "wget https://github.com/flrngel/FHC-Framework/archive/master.zip -O master.zip",() ->
		exec "unzip master.zip -d tmp",() ->
			exec "mv tmp/FHC-Framework-master "+dir,() ->
				exec "cd "+dir+" && ./install.sh && cd"+process.cwd(),() ->
					exec "rm -rf tmp master.zip",() ->
						console.log "URL /"+url+" is now running on directory \""+dir+"\""


else if mode == "update"

	if process.argv.length < 4
		console.log "usage: gaia update <directory>"
		process.exit 0

	dir=process.argv[3]
	
	exec=require("child_process").exec
	exec "wget https://github.com/flrngel/FHC-Framework/archive/master.zip -O master.zip",() ->
		exec "unzip master.zip -d tmp",() ->
			exec "cp -rf tmp/FHC-Framework-master/. "+dir,() ->
				exec "cd "+dir+" && ./install.sh && cd .. && rm -rf tmp master.zip",() ->
					console.log dir+" is now updated"

else if mode == "-v"

	pkg=require("./package.json")

	console.log "FHC-Gaia","("+pkg.version+")"
	console.log pkg.description
