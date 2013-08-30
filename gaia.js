#!/usr/bin/env node

var fs=require("fs");

if( process.argv.length < 5 ){
	console.log("usage: gaia new <directory> <url>");
	process.exit(0);
}
//////asdf
mode=process.argv[2];

if(mode == "new"){
	htaccess="";
	dir=process.argv[3];
	url=process.argv[4];
	url=url.replace(/\/+/,'');
	newStr="RewriteRule\t^"+url+"(.*)$\t"+dir+"/$1\t[L,QSA]\n";
	if( fs.existsSync(".htaccess") ){
		flag=false;
		stacked="";
		fs.readFileSync(".htaccess").toString().split("\n").forEach(function(line){
			if( flag < 2 ){
				if( line == "#Gaia Condition Start" ){
					flag=1;
					htaccess+=line+"\n";
				}else if( line == "#Gaia Condition End"){
					stacked+=line+"\n";
					htaccess+=newStr+stacked;
					flag=2;
				}else{
					if( flag == 0 ){
						htaccess+=line+"\n";
					}else if( flag == 1 ){
						stacked+=line+"\n";
					}
				}
			}else{
				if( line.length > 1 ){
					htaccess+=line+"\n";
				}
			}
		});
		fs.writeFileSync(".htaccess",htaccess.toString());
	}else{
		htaccess="#Created by FHC-Gaia\n";
		htaccess+="AddDefaultCharset UTF-8\n";
		htaccess+="RewriteEngine On\n";
		htaccess+="#---------------------------------------------------|\n";
		htaccess+="RewriteCond\t%{REQUEST_FILENAME}\t-f";
		htaccess+="RewriteRule\t.+\t-\t[L]";
		htaccess+="RewriteCond\t%{REQUEST_URI}\t!^$\n";
		htaccess+="#---------------------------------------------------|\n";
		htaccess+="#Gaia Condition Start\n";
		htaccess+=newStr;
		htaccess+="#Gaia Condition End\n";
		fs.writeFileSync(".htaccess",htaccess.toString());
	}
	// download zip
	var exec=require("child_process").exec;
	child=exec("wget https://github.com/flrngel/FHC-Framework/archive/master.zip",function(){
		child2=exec("unzip master.zip -d tmp",function(){
			child3=exec("mv tmp/FHC-Framework-master "+dir,function(){
				child5=exec("cd "+dir+" && ./install.sh && cd "+process.cwd(),function(){
					child4=exec("rm -rf tmp master.zip",function(){
						console.log("URL /"+url+" is now running on directory \""+dir+"\"");
					});
				});
			});
		});
	});
}
