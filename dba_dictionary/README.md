# Oracle Database - dba_dictionary view and documentation generator

History of changes:
- 1.0 - initial version

## Install instructions

Create the view in the target database schema.

## Usage

### The View 

This view provides a list of all dictionary views within Oracle database accompanied with column names and column comments.

It is similar to APEX_DICTIONARY view.

Read more on my blog post:

[https://zorantica.blogspot.com/2022/04/oracle-apexdictionary-and-dbadictionary.html](https://zorantica.blogspot.com/2022/04/oracle-apexdictionary-and-dbadictionary.html)

### Documentation Generatior

Big thanks goes to [Connor McDonald](https://connor-mcdonald.com/) and his blog post

[https://connor-mcdonald.com/2025/02/26/the-apex-data-dictionary/?unapproved=29590&moderation-hash=b30c9e18937ecb67f6a458b7b0413d4a#respond](https://connor-mcdonald.com/2025/02/26/the-apex-data-dictionary/?unapproved=29590&moderation-hash=b30c9e18937ecb67f6a458b7b0413d4a#respond)

I adapted his script for database dictionary views.

To generate the documentation download the script and run it from SQLPlus.

The result is a HTML file containing descriptions and details for all database dictionary views. An example can be found [here](dba_docs.html).