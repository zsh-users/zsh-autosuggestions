====================
shUnit2 2.1.x README
====================

code.google.com
===============

This project is stored on code.google.com as http://code.google.com/p/shunit2/.
All releases as of 2.1.4 and full source are available there. Documentation is
included as part of the source and each release. Source code is stored in
Subversion and can be accessed using the following information.

Browse the code in a web browser:

- http://code.google.com/p/shunit2/source/browse
- svn > trunk > source > 2.1

Check out the code locally ::

  $ svn checkout http://shunit2.googlecode.com/svn/trunk/ shflags-read-only


SourceForge
===========

DEPRECATED

This project is stored on SourceForge as http://sf.net/projects/shunit2. The
source code is stored in Subversion and can be accessed using the following
information.

Check out the code locally ::

  $ svn co https://shunit2.svn.sourceforge.net/svnroot/shunit2/trunk/source/2.1 shunit2

Browse the code in a web browser:

- http://shunit2.svn.sourceforge.net/viewvc/shunit2/trunk/source/2.1/
- http://shunit2.svn.sourceforge.net/svnroot/shunit2/trunk/source/2.1/


Making a release
================

For these steps, it is assumed we are working with release 2.0.0.

Steps:

- write release notes
- update version
- finish changelog
- check all the code in
- tag the release
- export the release
- create tarball
- md5sum the tarball and sign with gpg
- update website
- post to SourceForge and Freshmeat

Write Release Notes
-------------------

This should be pretty self explanatory. Use one of the release notes from a
previous release as an example.

The versions of the various platforms and shells are included when the
master unit test script is run, or when ``bin/gen_test_results.sh`` is
used. To determine the versions of the installed shells by hand, use the
``lib/versions`` script.

Alternatively, do the following:

+-------+---------+-----------------------------------------------------------+
| Shell | OS      | Notes                                                     |
+=======+=========+===========================================================+
| bash  |         | ``$ bash --version``                                      |
+-------+---------+-----------------------------------------------------------+
| dash  | Linux   | ``$ dpkg -l |grep dash``                                  |
+-------+---------+-----------------------------------------------------------+
| ksh   |         | ``$ ksh --version``                                       |
|       |         | -or-                                                      |
|       |         | ``$ echo 'echo $KSH_VERSION' |ksh``                       |
|       +---------+-----------------------------------------------------------+
|       | Cygwin  | see pdksh                                                 |
|       +---------+-----------------------------------------------------------+
|       | Solaris | ``$ strings /usr/bin/ksh |grep 'Version'``                |
+-------+---------+-----------------------------------------------------------+
| pdksh |         | ``$ strings /bin/pdksh |grep 'PD KSH'``                   |
|       +---------+-----------------------------------------------------------+
|       | Cygwin  | look in the downloaded Cygwin directory                   |
+-------+---------+-----------------------------------------------------------+
| sh    | Solaris | not possible                                              |
+-------+---------+-----------------------------------------------------------+
| zsh   |         | ``$ zsh --version``                                       |
+-------+---------+-----------------------------------------------------------+

Update Version
--------------

Edit ``src/shell/shunit2`` and change the version number in the comment, as well
as in the ``SHUNIT_VERSION`` variable.

Finish Documentation
--------------------

Make sure that any remaining changes get put into the ``CHANGES-X.X.txt`` file.

Finish writing the ``RELEASE_NOTES-X.X.X.txt``. If necessary, run it
through the **fmt** command to make it pretty (hopefully it is already). ::

  $ fmt -w 80 RELEASE_NOTES-2.0.0.txt >RELEASE_NOTES-2.0.0.txt.new
  $ mv RELEASE_NOTES-2.0.0.txt.new RELEASE_NOTES-2.0.0.txt

We want to have an up-to-date version of the documentation in the release, so
we'd better build it. ::

  $ pwd
  .../shunit2/source/2.1
  $ cd doc
  $ RST2HTML_OPTS='--stylesheet-path=rst2html.css'
  $ rst2html ${RST2HTML_OPTS} shunit2.txt >shunit2.html
  $ rst2html ${RST2HTML_OPTS} README.txt >README.html

Check In All the Code
---------------------

This step is pretty self-explanatory ::

  $ pwd
  .../shunit2/source/2.0
  $ svn ci -m "finalizing release"

Tag the Release
---------------
::

  $ pwd
  .../shunit2/source
  $ ls
  2.0  2.1
  $ svn cp -m "Release 2.0.0" 2.0 https://shunit2.googlecode.com/svn/tags/source/2.0.0

Export the Release
------------------
::

  $ pwd
  .../shunit2/builds
  $ svn export https://shunit2.googlecode.com/svn/tags/source/2.0.0 shunit2-2.0.0

Create Tarball
--------------
::

  $ tar cfz ../releases/shunit2-2.0.0.tgz shunit2-2.0.0

Sign the Tarball with gpg
-------------------------
::

  $ cd ../releases
  $ gpg --default-key kate.ward@forestent.com --detach-sign shunit2-2.0.0.tgz

Update Website
--------------

Again, pretty self-explanatory. Make sure to copy the GPG signature file. Once
that is done, make sure to tag the website so we can go back in time if needed.
::

  $ pwd
  .../shunit2
  $ ls
  source  website
  $ svn cp -m "Release 2.0.0" \
  website https://shunit2.googlecode.com/svn/tags/website/20060916

Now, update the website. It too is held in Subversion, so **ssh** into the web
server and use ``svn up`` to grab the latest version.

Post to code.google.com and Freshmeat
-------------------------------------

- http://code.google.com/p/shunit2/
- http://freshmeat.net/


Related Documentation
=====================

Docbook:
  http://www.docbook.org/

Docbook XML
  docbook-xml-4.4.zip:
    http://www.docbook.org/xml/4.4/docbook-xml-4.4.zip
    http://www.oasis-open.org/docbook/xml/4.4/docbook-xml-4.4.zip
  docbook-xml-4.5.zip:
    http://www.docbook.org/xml/4.5/docbook-xml-4.5.zip
Docbook XSL
  docbook-xsl-1.71.0.tar.bz2:
    http://prdownloads.sourceforge.net/docbook/docbook-xsl-1.71.0.tar.bz2?download
  docbook-xsl-1.71.1.tar.bz2:
    http://downloads.sourceforge.net/docbook/docbook-xsl-1.71.1.tar.bz2?use_mirror=puzzle
JUnit:
  http://www.junit.org/
reStructuredText:
  http://docutils.sourceforge.net/docs/user/rst/quickstart.html

.. generate HTML using rst2html from Docutils of
.. http://docutils.sourceforge.net/
..
.. vim:fileencoding=latin1:ft=rst:spell:tw=80
.. $Revision: 310 $
