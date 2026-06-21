// Query all subject records
query Listardisciplinas_ verb=GET {
  api_group = "Subjects"

  input {
  }

  stack {
    db.query subject {
      return = {type: "list"}
    } as $model
  }

  response = $model
}