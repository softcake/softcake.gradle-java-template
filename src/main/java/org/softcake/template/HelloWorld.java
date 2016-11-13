package org.softcake.template;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;


/**
 * @author Rene Neubert
 */
public class HelloWorld {


  private static final Logger LOGGER = LoggerFactory.getLogger(HelloWorld.class);

  private String name;


  public HelloWorld(String name) {
    this.name = name;
  }


  /**
   * @param args the arguments
   */
  public static void main(String[] args) {

    HelloWorld world = new HelloWorld("Hello");
    LOGGER.info(world.getName());
  }


  public String getName() {
    return name;
  }


  public void setName(String name) {
    this.name = name;
  }
}
