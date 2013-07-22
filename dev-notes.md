## Ports: 
- tomcat is on default port - 8080- (in guest) mapped to 8000 (host),
- nginx is on default port - 80 - (in guest) mapped to 8001 (host),
- apache is on port 85 (in guest) mapped to 8002 (host)

## Tomcat:
- [from Tomcat docs] the variable name `$CATALINA_BASE` [refers to]
  the base directory against which most relative paths are resolved.  If you
  have not configured Tomcat for multiple instances by setting a 
  `CATALINA_BASE` directory, then `$CATALINA_BASE` will be set to the value 
  of `$CATALINA_HOME`, the directory into which you have installed Tomcat.
- by default `$CATALINE_HOME` is `/var/lib/tomcat[version]` 
- Catalina is Tomcat's servlet container module; it implements Sun's
  definition of Java Server Pages
- Every web application should register itself to Catalina via context elements
  which are XML blocks defining properties of the application. Context elements
  should either be placed in an independent context file or be an XML
  block inside Tomcat's `server.xml` (in `/etc/tomcat6` in Debian/Ubuntu).
  Independent context elements, i.e context files, should be placed in the directory
  `/etc/tomcat6/Catalina/localhost` in Debian/Ubuntu. 
- In a context file you define three main attributes `docBase` and `path` for your
  web app. 
  - `path` is the path under which your web app can be accessed (e.g
  `[fqdn]/[path]`). If the context element is in a context file (as opposed to
  an added XML block inside `server.xml`) this attribute
  cannot be used since it is automatically set to the name of the `xml` file, so
  if your application's context file is `solr.xml` it would be served under
  `/solr` relative to Tomcat's FQDN.
  - `docbase` [from docs] The Document Base (also known as the **Context Root**)
  directory for this web application, or the pathname to the web application
  archive file (if this web application is being executed directly from the WAR
  file). You may specify an absolute pathname for this directory or WAR file, or
  a pathname that is relative to the appBase directory of the owning Host.
  - Envirotnment entries: xml blocks in the context element that configure named
  values that will be then exposed to the application. For example,
     <Context ...>
       ...
       <Environment name="maxExemptions"
                    value="10"
                    type="java.lang.Integer"
                    override="false"/>
       ...
     </Context>
  `name`, `value`, `type`, `override`, and `description` are all attributes you
  can use in environment blocks.
## Solr:
- define context element for Solr:
      <Context docBase="/opt/solr/solr.war" debug="0" crossContext="true">
        <Environment name="solr/home" type="java.lang.String" value="/opt/solr/org" override="true" />
        <Valve className="org.apache.catalina.valves.AccessLogValve" prefix="access_log_org"/>
        <!-- Uncomment the next line to enable IP based security 
        <Valve className="org.apache.catalina.valves.RemoteAddrValve" allow="76\.10\.176\.148,127\.0\.0\.1"/>
        -->
      </Context>
- this sets solr home to `/opt/solr/org` 
- tells tomcat to expect to find `solr.war` in `/opt/solr`, and Tomcat will then
  expand this into the `/var/lib/tomcat6/webapps/org` directory.
- We now need to prepare the solr home directory (as defined in the context
  element to be at `/opt/solr/org/`). This directory must contain solr's own
  configuration files (not Tomcat's responsibility). You can use the example
  directory in the tar file you download for solr (under
  `apache-solr-1.4.0/example/solr/`).
- Now we have to fix solr config files that we just placed under solr home, to
  respect our setting. In `[solr/home]/conf/solrconfig.xml`, this line has to be
  modified to reflect our setup:
    <dataDir>${solr.data.dir:/opt/solr/org/data}</dataDir>
- At this point if the Tomcat user has appropriate permissions on the solr home
  directory, things would be good.

## Drupal and Solr
- I will be using the
  [Apache Solr Search Integration](https://drupal.org/project/apachesolr) 
  module for Solr integration. This module allows you to use the
  [Facet API module](https://drupal.org/project/facetapi) module if
  you intend to use Solr for faceted search.
- [from docs] The module comes with `schema.xml`, `solrconfig.xml`, and
  `protwords.txt` files which **must** be used in your Solr installation in
  order to get the module to work correctly.
- install the module by `sudo drush dl apachesolr`. Before enabling the module,
  the `solr-php-client` PHP library should be downloaded (from
  http://code.google.com/p/solr-php-client/). For some reason, the module only
  expects the php-client to be a revision 22 make (`r22`, see link). This should
  be placed under the module directory under the name `SolrPhpClient`.
- You should also move the three files `protwords.txt`, `schema.xml`, and
  `solrconfig.xml` that the package comes with and put them in the solr home
  (overwrite existing files).
- now enable the module `drush en apachesolr`, and configure the module to talk
  to the right solr server (in my case `localhost:8080/org`).
