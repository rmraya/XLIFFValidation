# XLIFFValidation

 Web-based XLIFF validation writen in Java and TypeScript

## XLIFF Validation Service

You can validate your XLIFF files at [https://dev.maxprograms.com/Validation/](https://dev.maxprograms.com/Validation/)

## Requirements

- JDK 21  is required for compiling and building. Get it from [Adoptium](https://adoptium.net/).
- Apache Ant 1.10.13 or newer. Get it from [https://ant.apache.org/](https://ant.apache.org/)
- Node.js 20.10.0 LTS or newer. Get it from [https://nodejs.org/](https://nodejs.org/)
- TypeScript 5.3.3 or newer. get it from [https://www.typescriptlang.org/](https://www.typescriptlang.org/)

## Building

- Checkout this repository.
- Point your `JAVA_HOME` environment variable to JDK 21
- Run `npm install` to download and install NodeJS dependencies
- Run `ant` to compile the Java code and generate `Validation.war`

## Deploying

- Configure an instance of [Apache Tomcat 9.x](https://tomcat.apache.org) to run in secure mode, with HTTPS protocol
- Copy `validation.war` to Tomcat's `webapps` folder
- Set `XLIFF_HOME` environment variable, pointing to a folder in your server
- Copy `catalog` folder to `XLIFF_HOME/catalog`
- Copy `xsl` folder to `XLIFF_HOME/xsl`
- Start Tomcat
