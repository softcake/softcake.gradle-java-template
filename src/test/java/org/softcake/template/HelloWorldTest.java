package org.softcake.template;


import org.junit.Before;
import org.junit.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import static org.junit.Assert.assertEquals;


/**
 * @author Rene Neubert
 */
public class HelloWorldTest {


  private static final Logger LOGGER = LoggerFactory.getLogger(HelloWorld.class);
  private String name;
  private HelloWorld helloWorld;


  @Before
  public void setUp() {
    this.helloWorld = new HelloWorld("Hello World!");
    this.name = "Hello World!";
  }

  @Test
  public void getName() {
    String s = this.helloWorld.getName();
    assertEquals(s, name);
  }

  @Test
  public void setName() {
    this.name = "Hello Mars!";
    this.helloWorld.setName("Hello Mars!");
    String s = this.helloWorld.getName();
    assertEquals("expected name ar equal", s, name);
  }
  @Test
  public void main() {
    String[] args =  new String[1];
    args[0] = "Hello!";
    HelloWorld.main(args);
  }
}