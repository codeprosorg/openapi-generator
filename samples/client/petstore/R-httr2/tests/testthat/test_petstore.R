context("basic functionality")

## create a new pet and add to petstore server
pet_api <- PetApi$new()
pet_id <- 123321
pet <- Pet$new("name_test",
  photoUrls = list("photo_test", "second test"),
  category = Category$new(id = 450, name = "test_cat"),
  id = pet_id,
  tags = list(
    Tag$new(id = 123, name = "tag_test"), Tag$new(id = 456, name = "unknown")
  ),
  status = "available"
)
pet_api$api_client$username <- "username123"
pet_api$api_client$password <- "password123"
result <- pet_api$add_pet(pet)

test_that("Test toJSON toJSONString fromJSON fromJSONString", {
  # test pet
  expect_equal(pet_id, 123321)
  expect_equal(pet$toJSONString(), '{"id":123321,"category":{"id":450,"name":"test_cat"},"name":"name_test","photoUrls":["photo_test","second test"],"tags":[{"id":123,"name":"tag_test"},{"id":456,"name":"unknown"}],"status":"available"}')

  # tests for other pet objects
  pet0 <- Pet$new()
  jsonpet <- pet0$toSimpleType()
  pet2 <- pet0$fromJSON(
    jsonlite::toJSON(jsonpet, auto_unbox = TRUE)
  )
  expect_equal(pet0, pet2)
  jsonpet <- pet0$toJSONString()
  pet2 <- pet0$fromJSON(
    jsonpet
  )
  expect_equal(pet0, pet2)

  jsonpet <- pet0$toJSONString()
  pet2 <- pet0$fromJSONString(
    jsonpet
  )
  expect_equal(pet0, pet2)

  pet1 <- Pet$new("name_test",
    list("photo_test", "second test"),
    category = Category$new(id = 450, name = "test_cat"),
    id = pet_id,
    tags = list(
      Tag$new(id = 123, name = "tag_test"), Tag$new(id = 456, name = "unknown")
    ),
    status = "available"
  )
  jsonpet <- pet1$toSimpleType()
  pet2 <- pet1$fromJSON(
    jsonlite::toJSON(jsonpet, auto_unbox = TRUE)
  )
  expect_equal(pet1, pet2)

  jsonpet <- pet1$toJSONString()
  pet2 <- pet1$fromJSON(
    jsonpet
  )
  expect_equal(pet1, pet2)

  jsonpet <- pet1$toJSONString()
  pet2 <- pet1$fromJSONString(
    jsonpet
  )
  expect_equal(pet1, pet2)
})

test_that("Test Category", {
  c1 <- Category$new(id = 450, name = "test_cat")
  c2 <- Category$new()
  c2$fromJSON(jsonlite::toJSON(c1$toSimpleType(), auto_unbox = TRUE))
  expect_equal(c1, c2)
  c2$fromJSONString(c1$toJSONString())
  expect_equal(c1, c2)
})

test_that("get_pet_by_id", {
  response <- pet_api$get_pet_by_id(pet_id)
  expect_equal(response$id, pet_id)
  expect_equal(response$name, "name_test")
  expect_equal(
    response$photoUrls,
    list("photo_test", "second test")
  )
  expect_equal(response$status, "available")
  expect_equal(response$category, Category$new(id = 450, name = "test_cat"))

  expect_equal(pet$tags, response$tags)
  expect_equal(
    response$tags,
    list(Tag$new(id = 123, name = "tag_test"), Tag$new(id = 456, name = "unknown"))
  )
})

test_that("update_pet_with_form", {
  ## add pet
  update_pet_id <- 123999
  update_pet <- Pet$new("name_test",
    photoUrls = list("photo_test", "second test"),
    category = Category$new(id = 450, name = "test_cat"),
    id = update_pet_id,
    tags = list(
      Tag$new(id = 123, name = "tag_test"), Tag$new(id = 456, name = "unknown")
    ),
    status = "available"
  )
  pet_api$api_client$username <- "username123"
  pet_api$api_client$password <- "password123"
  result <- pet_api$add_pet(update_pet)

  ## update pet with form
  pet_api$api_client$oauth_client_id <- "client_id_aaa"
  pet_api$api_client$oauth_secret <- "secrete_bbb"
  pet_api$api_client$oauth_scopes <- "write:pets read:pets"
  update_result <- pet_api$update_pet_with_form(update_pet_id, name = "pet2", status = "sold")

  # get pet
  response <- pet_api$get_pet_by_id(update_pet_id)
  expect_equal(response$id, update_pet_id)
  expect_equal(response$name, "pet2")
  expect_equal(response$status, "sold")
  expect_equal(
    response$photoUrls,
    list("photo_test", "second test")
  )
  expect_equal(response$category, Category$new(id = 450, name = "test_cat"))

  expect_equal(pet$tags, response$tags)
  expect_equal(
    response$tags,
    list(Tag$new(id = 123, name = "tag_test"), Tag$new(id = 456, name = "unknown"))
  )
})

test_that("get_pet_by_id_streaming", {
  result <- tryCatch(
               pet_api$get_pet_by_id_streaming(pet_id, stream_callback = function(x) { print(x) }),
               ApiException = function(ex) ex
            )
})

test_that("Test header parameters", {
  # test exception 
  result <- tryCatch(pet_api$test_header(45345), 
          ApiException = function(ex) ex
  )

  expect_true(!is.null(result))
  expect_true(!is.null(result$ApiException))
  expect_equal(result$ApiException$status, 404)
  # test error object `ApiResponse`
  #expect_equal(result$ApiException$error_object$toString(), "{\"code\":404,\"type\":\"unknown\",\"message\":\"null for uri: http://pet\n  x[1]: store.swagger.io/v2/pet_header_test\"}")
  expect_equal(result$ApiException$error_object$code, 404)
})


test_that("Test GetPetById exception", {
  # test exception
  result <- tryCatch(pet_api$get_pet_by_id(98765), # petId not exist
          ApiException = function(ex) ex
  )

  expect_true(!is.null(result))
  expect_true(!is.null(result$ApiException))
  expect_equal(result$ApiException$status, 404)
  # test error object `ApiResponse`
  expect_equal(result$ApiException$error_object$toString(), "{\"code\":1,\"type\":\"error\",\"message\":\"Pet not found\"}")
  expect_equal(result$ApiException$error_object$code, 1)
})

test_that("GetPetById with data_file", {
  # test to ensure json is saved to the file `get_pet_by_id.json`
  pet_response <- pet_api$get_pet_by_id(pet_id, data_file = "get_pet_by_id.json")
  response <- read_json("get_pet_by_id.json")
  expect_true(!is.null(response))
  expect_equal(response$id, pet_id)
  expect_equal(response$name, "name_test")
})

test_that("Tests allOf", {
  # test allOf without discriminator
  a1 <- AllofTagApiResponse$new(id = 450, name = "test_cat", code = 200, type = "test_type", message = "test_message")
  
  expect_true(!is.null(a1))
  expect_equal(a1$id, 450)
  expect_equal(a1$name, "test_cat")
})

test_that("Tests allOf with discriminator", {
  # test allOf without discriminator
  c1 <- Cat$new(className = "cat", color = "red", declawed = TRUE)
  
  expect_true(!is.null(c1))
  expect_equal(c1$className, "cat")
  expect_equal(c1$color, "red")
  expect_true(c1$declawed)
})

test_that("Tests validateJSON", {
  json <-
  '{"name": "pet", "photoUrls" : ["http://a.com", "http://b.com"]}'
  
  json2 <-
  '[
    {"Name" : "Tom", "Age" : 32, "Occupation" : "Consultant"}, 
    {},
    {"Name" : "Ada", "Occupation" : "Engineer"}
  ]'

  # validate `json` and no error throw
  Pet$public_methods$validateJSON(json)

  # validate `json2` and should throw an error due to missing required fields
  #expect_error(Pet$public_methods$validateJSON(json2), 'The JSON input ` [\n    {\"Name\" : \"Tom\", \"Age\" : 32, \"Occupation\" : \"Consultant\"}, \n    {},\n    {\"Name\" : \"Ada\", \"Occupation\" : \"Engineer\"}\n  ] ` is invalid for Pet: the required field `name` is missing.')
  
})

# test object with special item names: self, private, super
test_that("Tests special item names", {
  special_json <-
  '{"self": 123, "private": "red", "super": "something"}'

  # test fromJSON
  special <- Special$new()$fromJSON(special_json)
  expect_equal(special$item_self, 123)
  expect_equal(special$item_private, "red")
  expect_equal(special$item_super, "something")

  # test toJSONString 
  expect_true(grepl('"private"', special$toJSONString()))
  expect_true(grepl('"self"', special$toJSONString()))
  expect_true(grepl('"super"', special$toJSONString()))
  expect_equal('{"self":123,"private":"red","super":"something"}', special$toJSONString())

  # round trip test
  s1 <- Special$new()$fromJSONString(special_json)
  s2 <- Special$new()$fromJSONString(s1$toJSONString())
  expect_equal(s1, s2)

})

test_that ("Tests validations", {
  invalid_pet <- Pet$new()

  expect_false(invalid_pet$isValid())

  invalid_fields <- invalid_pet$getInvalidFields()
  expect_equal(invalid_fields[["name"]], "Non-nullable required field `name` cannot be null.")
  expect_equal(invalid_fields[["photoUrls"]], "Non-nullable required field `photoUrls` cannot be null.")

  # fix invalid fields
  invalid_pet$name <- "valid pet"
  invalid_pet$photoUrls <- list("photo_test", "second test")

  expect_true(invalid_pet$isValid())
  expect_equal(invalid_pet$getInvalidFields(), list())

})

test_that("Tests oneOf primitive types", {
  test <- OneOfPrimitiveTypeTest$new()
  test$fromJSONString("\"123abc\"")
  expect_equal(test$actual_instance,  '123abc')
  expect_equal(test$actual_type,  'character')

  test$fromJSONString("456")
  expect_equal(test$actual_instance,  456)
  expect_equal(test$actual_type,  'integer')

  expect_error(test$fromJSONString("[45,12]"), "No match found when deserializing the input into OneOfPrimitiveTypeTest with oneOf schemas character, integer. Details: >> Data type doesn't match. Expected: integer. Actual: list. >> Data type doesn't match. Expected: character. Actual: list.") # should throw an error
})

test_that("Tests anyOf primitive types", {
  test <- AnyOfPrimitiveTypeTest$new()
  test$fromJSONString("\"123abc\"")
  expect_equal(test$actual_instance,  '123abc')
  expect_equal(test$actual_type,  'character')

  test$fromJSONString("456")
  expect_equal(test$actual_instance,  456)
  expect_equal(test$actual_type,  'integer')

  expect_error(test$fromJSONString("[45,12]"), "No match found when deserializing the input into AnyOfPrimitiveTypeTest with oneOf schemas character, integer. Details: >> Data type doesn't match. Expected: integer. Actual: list. >> Data type doesn't match. Expected: character. Actual: list.") # should throw an error
})

test_that("Tests oneOf", {
  basque_pig_json <-
  '{"className": "BasquePig", "color": "red"}'

  danish_pig_json <-
  '{"className": "DanishPig", "size": 7}'

  wrong_json <- 
  '[
    {"Name" : "Tom", "Age" : 32, "Occupation" : "Consultant"}, 
    {},
    {"Name" : "Ada", "Occupation" : "Engineer"}
  ]'

  original_danish_pig <- DanishPig$new()$fromJSON(danish_pig_json)
  original_basque_pig <- BasquePig$new()$fromJSON(basque_pig_json)

  # test fromJSON, actual_tpye, actual_instance
  pig <- Pig$new()
  danish_pig <- pig$fromJSON(danish_pig_json)
  pig$validateJSON(basque_pig_json) # validate JSON to ensure its actual_instance, actual_type are not updated
  expect_equal(danish_pig$actual_type, "DanishPig")
  expect_equal(danish_pig$actual_instance$size, 7)
  expect_equal(danish_pig$actual_instance$className, "DanishPig")

  expect_equal(pig$actual_type, "DanishPig")
  expect_equal(pig$actual_instance$size, 7)
  expect_equal(pig$actual_instance$className, "DanishPig")

  # test toJSON
  expect_equal(danish_pig$toJSONString(), original_danish_pig$toJSONString())

  basque_pig <- pig$fromJSON(basque_pig_json)
  expect_equal(basque_pig$actual_type, "BasquePig")
  expect_equal(basque_pig$actual_instance$color, "red")
  expect_equal(basque_pig$actual_instance$className, "BasquePig")
  expect_equal(basque_pig$toJSONString(), original_basque_pig$toJSONString())

  # test exception when no matche found
  expect_error(pig$fromJSON('{}'), 'No match found when deserializing the input into Pig with oneOf schemas BasquePig, DanishPig. Details: >> The JSON input ` \\{\\} ` is invalid for BasquePig: the required field `className` is missing\\. >> The JSON input ` \\{\\} ` is invalid for DanishPig: the required field `className` is missing\\.')
  expect_error(pig$validateJSON('{}'), 'No match found when deserializing the input into Pig with oneOf schemas BasquePig, DanishPig. Details: >> The JSON input ` \\{\\} ` is invalid for BasquePig: the required field `className` is missing\\. >> The JSON input ` \\{\\} ` is invalid for DanishPig: the required field `className` is missing\\.')

  # class name test
  expect_equal(get(class(basque_pig$actual_instance)[[1]], pos = -1)$classname, "BasquePig")

  # test constructors
  pig2 <- Pig$new(instance = basque_pig$actual_instance)
  expect_equal(pig2$actual_type, "BasquePig")
  expect_equal(pig2$actual_instance$color, "red")
  expect_equal(pig2$actual_instance$className, "BasquePig")
  expect_equal(pig2$toJSONString(), original_basque_pig$toJSONString())

  expect_error(Pig$new(instance = basque_pig), 'Failed to initialize Pig with oneOf schemas BasquePig, DanishPig. Provided class name:  Pig')

  # test nested oneOf toJSONString
  nested_oneof <- NestedOneOf$new()
  nested_oneof$nested_pig <- pig
  nested_oneof$size <- 15
  expect_equal(nested_oneof$toJSONString(), '{"size":15,"nested_pig":{"className":"BasquePig","color":"red"}}')

  # test fromJSONString with nested oneOf
  nested_json_str <- '{"size":15,"nested_pig":{"className":"BasquePig","color":"red"}}'
  nested_oneof2 <- NestedOneOf$new()$fromJSONString(nested_json_str)
  expect_equal(nested_oneof2$toJSONString(), '{"size":15,"nested_pig":{"className":"BasquePig","color":"red"}}')

  # test toString
  expect_equal(as.character(jsonlite::minify(pig$toString())), "{\"actual_instance\":{\"className\":\"BasquePig\",\"color\":\"red\"},\"actual_type\":\"BasquePig\",\"one_of\":\"BasquePig, DanishPig\"}")
  expect_equal(as.character(jsonlite::minify(Pig$new()$toString())), "{\"one_of\":\"BasquePig, DanishPig\"}")
})

test_that("Tests anyOf", {
  basque_pig_json <-
  '{"className": "BasquePig", "color": "red"}'

  danish_pig_json <-
  '{"className": "DanishPig", "size": 7}'

  wrong_json <- 
  '[
    {"Name" : "Tom", "Age" : 32, "Occupation" : "Consultant"}, 
    {},
    {"Name" : "Ada", "Occupation" : "Engineer"}
  ]'

  original_danish_pig <- DanishPig$new()$fromJSON(danish_pig_json)
  original_basque_pig <- BasquePig$new()$fromJSON(basque_pig_json)

  # test fromJSON, actual_tpye, actual_instance
  pig <- AnyOfPig$new()
  danish_pig <- pig$fromJSON(danish_pig_json)
  expect_equal(danish_pig$actual_type, "DanishPig")
  expect_equal(danish_pig$actual_instance$size, 7)
  expect_equal(danish_pig$actual_instance$className, "DanishPig")

  expect_equal(pig$actual_type, "DanishPig")
  expect_equal(pig$actual_instance$size, 7)
  expect_equal(pig$actual_instance$className, "DanishPig")

  # test toJSONString
  expect_equal(danish_pig$toJSONString(), original_danish_pig$toJSONString())

  basque_pig <- pig$fromJSON(basque_pig_json)
  expect_equal(basque_pig$actual_type, "BasquePig")
  expect_equal(basque_pig$actual_instance$color, "red")
  expect_equal(basque_pig$actual_instance$className, "BasquePig")
  expect_equal(basque_pig$toJSONString(), original_basque_pig$toJSONString())

  # test exception when no matche found
  expect_error(pig$fromJSON('{}'), 'No match found when deserializing the input into AnyOfPig with anyOf schemas BasquePig, DanishPig. Details: >> The JSON input ` \\{\\} ` is invalid for BasquePig: the required field `className` is missing\\. >> The JSON input ` \\{\\} ` is invalid for DanishPig: the required field `className` is missing\\.')
  expect_error(pig$validateJSON('{}'), 'No match found when deserializing the input into AnyOfPig with anyOf schemas BasquePig, DanishPig. Details: >> The JSON input ` \\{\\} ` is invalid for BasquePig: the required field `className` is missing\\. >> The JSON input ` \\{\\} ` is invalid for DanishPig: the required field `className` is missing\\.')

})
