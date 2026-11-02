FROM eclipse-temurin
WORKDIR /app
COPY Hello.java /app
RUN javac Hello.java
CMD ["java","Hello.java"]
