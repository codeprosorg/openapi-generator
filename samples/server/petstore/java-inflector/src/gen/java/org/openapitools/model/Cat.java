package org.openapitools.model;

import java.util.Objects;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonCreator;
import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiModelProperty;
import org.openapitools.model.Animal;





@javax.annotation.Generated(value = "org.openapitools.codegen.languages.JavaInflectorServerCodegen", comments = "Generator version: 7.11.0-SNAPSHOT")
public class Cat extends Animal  {
  @JsonProperty("declawed")
  private Boolean declawed;

  /**
   **/
  public Cat declawed(Boolean declawed) {
    this.declawed = declawed;
    return this;
  }

  
  @ApiModelProperty(value = "")
  @JsonProperty("declawed")
  public Boolean getDeclawed() {
    return declawed;
  }
  public void setDeclawed(Boolean declawed) {
    this.declawed = declawed;
  }


  @Override
  public boolean equals(Object o) {
    if (this == o) {
      return true;
    }
    if (o == null || getClass() != o.getClass()) {
      return false;
    }
    Cat cat = (Cat) o;
    return super.equals(o) && Objects.equals(declawed, cat.declawed);
  }

  @Override
  public int hashCode() {
    return Objects.hash(super.hashCode(), declawed);
  }

  @Override
  public String toString() {
    StringBuilder sb = new StringBuilder();
    sb.append("class Cat {\n");
    sb.append("    ").append(toIndentedString(super.toString())).append("\n");
    sb.append("    declawed: ").append(toIndentedString(declawed)).append("\n");
    sb.append("}");
    return sb.toString();
  }

  /**
   * Convert the given object to string with each line indented by 4 spaces
   * (except the first line).
   */
  private String toIndentedString(Object o) {
    if (o == null) {
      return "null";
    }
    return o.toString().replace("\n", "\n    ");
  }
}

