# "Wrapper" utility

The Wrapper utility provides You functionality to wrap PL/SQL code stored in Your local files (for example in a versioning control repository like GIT or SVN) in case that You do not have Oracle command line wrap utility available, which comes with a full database installation only.

## How the Utility works

The PL/SQL code is fetched from local computer, sent to the database to be wrapped and the wrapped result is stored back on the local computer.

The whole process requires 3 building blocks:

1. local bash script file
2. ORDS REST Service module
3. database package containing a fuction for wrapping

The local bash script stored on Your computer is fetching a content of local files conatining PL/SQL code.

A content of local files is sent one by one to the ORDS REST service via POST request by using a well known CURL utility.

ORDS module is then calling a database PL/SQL function and passes a content of file received in the request. The function wraps a code and returns wrapped code to the ORDS module, which passes it back as a response to the bash script.

Bash script is then storing a recieved wrapped content in the separate local file so that the original PL/SQL code is not overwritten.

## Prerequisites

### CURL Utility

If You don't have one on Your computer please download and install it from here.

<https://curl.se/download.html>

### SH Utility

Windows does not natively supports an execution of SH files (script shell).

But You may download and install either [CygWin](http://cygwin.com/install.html) or Git for Windows (with bash enabled).

## Install Instructions

### Download Bash Script

Download [a bash script file](https://github.com/zorantica/db_apex_utils/blob/main/wrapper/wrap_packages.sh) and store it on Your local computer.

*I prefer to store it in the folder with PL/SQL source files or in the parent folder.*

### Prepare A list of Files to wrap

Download [an example TXT file](https://github.com/zorantica/db_apex_utils/blob/main/wrapper/wrap_list.txt) named wrap_list.txt.

Store a file in the same folder as bash script.

Populate TXT file with a list of files You want to wrap.

### Install a Database PL/SQL Package for wrapping

Download [package specification and body](https://github.com/zorantica/db_apex_utils/blob/main/wrapper/pkg_wrap.sql).

Pick a desired database schema and install the downloaded package there (simply execute a downloaded script via Your preferred client tool like SQL Developer, SQLPlus, SQLCl...).

**Warning. An "execute" privilege for the package dbms_ddl is required in order to compile and use downloaded wrap package! If Your schema does not have this privilege contact Your DBA.**

### Create an ORDS Module

Download [SQL script for creating an ORDS module](https://github.com/zorantica/db_apex_utils/blob/main/wrapper/ORDS.sql).

Connect to the schema where You installed a wrap PL/SQL package and execute the script. This way You'll enable the schema for ORDS and create an ORDS module for wrapping.

### Configure Bach Script File

Open the bash script file with Your preffered text editor.

At the beginning of the script (line 4) enter a correct name of the file containing a list of files to wrap. *The default one is wrap_list.txt just like the one You downloaded and populated.*

Line 3 contains an URL of the ORDS service created in the previous chapter. *If You have Oracle APEX or SQL Developer Web available You may quickly find the URL.*

Otherwise the following SELECT statement helps:

```sql
SELECT apex_util.host_url('SCRIPT') || lower(sys_context('USERENV', 'CURRENT_USER')) || m.uri_prefix || t.uri_template AS full_url,
       m.name         AS module_name,
       t.uri_template AS template,
       h.method       AS http_method
FROM   user_ords_modules   m
JOIN   user_ords_templates t ON t.module_id = m.id
JOIN   user_ords_handlers  h ON h.template_id = t.id;
```

Optionally adapt the wrapped file name pattern in the line 23. By default, wrapped files contain the same filename as the original non-wrapped source files plus WRP extension.

## Usage

Simply execute the Bash Script file and wait until it finishes.

Every source file which is going to be wrapped is stated in prompt output so You may trace the progress.

## Security

Exposing unprotected ORDS modules can lead to security issues and it is recommended to protect modules at least with basic authentication or more secure mechanism like OAuth2.

There is a lot of documentation on how to implement security in ORDS, for example the basic authentication:

<https://blogs.oracle.com/cloud-infrastructure/post/ords-basic-authentication-with-oracle-apex>

In that case You need to alter the SH bash script and adapt CURL calls to include additional parameters for authentication (lines 34-36). Like this:

```sh
#credentials
USERNAME="your_username"
PASSWORD="your_password"

RESPONSE=$(curl -s -X POST "$WRAP_URL" \
    -u "$USERNAME:$PASSWORD" \
    -H "Content-Type: text/plain" \
    --data-binary @"$INPUT_FILE")
```

## History of changes

- 1.0 - initial version
