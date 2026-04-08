# Architecture rules

- Scan the codebase before making changes.
- Follow standard CVM architecture using Core, Modules, and Routes.
- Models are the source of truth.
- Services receive payload models and return UI models from API JSON using toJson/fromJson.
- Controllers expose reactive models to the UI and update fields using copyWith.
- Controllers call services through the API error handler.
- API error handler returns a fixed response model object (defined within the same file) with data<T>, success flag, and errorCode, and handles user-facing errors consistently. 
- Each module should have dedicated model, service, controller, and view files/folders.
- Shared logic across modules should go into a shared module/submodule.
- Cross-cutting services/models/controllers go in Core.


## Code Quality Rules

- Avoid redundant wrapper methods.
- Do not create pass-through methods that only call another method without adding logic.
- Do not create both `fromJson` and `fromMap` unless they have distinct responsibilities.
- Prefer a single source of truth for model parsing.
- Every method must have a clear responsibility (transformation, validation, or abstraction).
- If a method only forwards parameters without modification, it should be removed.
- Redundant abstraction is not allowed.
- Wrapper methods must only exist if they introduce transformation or domain logic.
- use the direct values from the backend response.
refer to the postman sollection json for the variable names.
- Do not use list of keys/guesses to read from the json, only use the documented variable names from the postman collection json.
- Only use backend data to hydrate existing UI models, do not create new models or UI elements based on the backend response. 
- IMPORTANT: if the json does not contain the proper variable names implement a single variable name and place comment stating ("Postman does not contain the proper variable name") and IMMEDIATELY add comments and report back such empty states to the user.
- Direct delegation without logic is considered a violation.