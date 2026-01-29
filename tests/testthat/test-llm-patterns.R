# Tests for LLM/AI detection patterns

test_that("R LLM patterns exist and are valid", {
  patterns <- get_detection_patterns("r", type = "input")

  # Check that we have ellmer patterns
  ellmer_funcs <- sapply(patterns, function(p) p$func)
  expect_true("chat_openai" %in% ellmer_funcs)
  expect_true("chat_claude" %in% ellmer_funcs)
  expect_true("chat_ollama" %in% ellmer_funcs)
  expect_true("chat_gemini" %in% ellmer_funcs)
  expect_true("chat_groq" %in% ellmer_funcs)
  expect_true("chat_azure" %in% ellmer_funcs)

  # Check tidyllm pattern
  expect_true("llm_message" %in% ellmer_funcs)

  # Verify patterns are well-formed
  for (p in patterns) {
    expect_true(!is.null(p$regex))
    expect_true(!is.null(p$func))
    expect_true(!is.null(p$description))
  }
})

test_that("Python LLM input patterns exist and are valid", {
  patterns <- get_detection_patterns("python", type = "input")

  # Check that we have LLM patterns
  funcs <- sapply(patterns, function(p) p$func)

  # Ollama
  expect_true("ollama.chat" %in% funcs)
  expect_true("ollama.generate" %in% funcs)
  expect_true("ollama.embeddings" %in% funcs)


  # OpenAI
  expect_true("OpenAI" %in% funcs)
  expect_true("client.chat.completions.create" %in% funcs)
  expect_true("client.embeddings.create" %in% funcs)

  # Anthropic
  expect_true("Anthropic" %in% funcs)
  expect_true("anthropic.Anthropic" %in% funcs)
  expect_true("client.messages.create" %in% funcs)

  # LangChain
  expect_true("ChatOpenAI" %in% funcs)
  expect_true("ChatAnthropic" %in% funcs)
  expect_true("ChatOllama" %in% funcs)
  expect_true("LLMChain" %in% funcs)

  # Transformers
  expect_true("AutoModelForCausalLM.from_pretrained" %in% funcs)
  expect_true("AutoTokenizer.from_pretrained" %in% funcs)

  # LiteLLM
  expect_true("litellm.completion" %in% funcs)
  expect_true("litellm.embedding" %in% funcs)

  # vLLM
  expect_true("LLM" %in% funcs)
  expect_true("vllm.LLM" %in% funcs)

  # Groq
  expect_true("Groq" %in% funcs)
})

test_that("Python LLM output patterns exist and are valid", {
  patterns <- get_detection_patterns("python", type = "output")

  # Check that we have model save patterns
  funcs <- sapply(patterns, function(p) p$func)

  # Transformers
  expect_true("model.save_pretrained" %in% funcs)
  expect_true("tokenizer.save_pretrained" %in% funcs)
  expect_true("trainer.save_model" %in% funcs)

  # PyTorch
  expect_true("torch.save" %in% funcs)
  expect_true("torch.onnx.export" %in% funcs)

  # Keras
  expect_true("model.save" %in% funcs)
  expect_true("model.save_weights" %in% funcs)

  # MLflow
  expect_true("mlflow.log_model" %in% funcs)
})

test_that("LLM patterns have valid regex", {
  # Test R patterns
  r_patterns <- get_detection_patterns("r", type = "input")
  for (p in r_patterns) {
    # Each regex should compile without error
    expect_no_error(grepl(p$regex, "test string"))
  }

  # Test Python input patterns
  py_input <- get_detection_patterns("python", type = "input")
  for (p in py_input) {
    expect_no_error(grepl(p$regex, "test string"))
  }

  # Test Python output patterns
  py_output <- get_detection_patterns("python", type = "output")
  for (p in py_output) {
    expect_no_error(grepl(p$regex, "test string"))
  }
})

test_that("LLM patterns match expected code snippets", {
  # Test OpenAI pattern
  py_patterns <- get_detection_patterns("python", type = "input")
  openai_pattern <- py_patterns[[which(sapply(py_patterns, function(p) p$func == "OpenAI"))]]
  expect_true(grepl(openai_pattern$regex, "client = OpenAI(api_key='sk-xxx')"))

  # Test Anthropic pattern
  anthropic_pattern <- py_patterns[[which(sapply(py_patterns, function(p) p$func == "Anthropic"))]]
  expect_true(grepl(anthropic_pattern$regex, "client = Anthropic(api_key='sk-xxx')"))

  # Test ollama pattern
  ollama_pattern <- py_patterns[[which(sapply(py_patterns, function(p) p$func == "ollama.chat"))]]
  expect_true(grepl(ollama_pattern$regex, "ollama.chat(model='llama2')"))

  # Test langchain patterns
  langchain_pattern <- py_patterns[[which(sapply(py_patterns, function(p) p$func == "ChatOpenAI"))]]
  expect_true(grepl(langchain_pattern$regex, "llm = ChatOpenAI(model='gpt-4')"))

  # Test R ellmer pattern
  r_patterns <- get_detection_patterns("r", type = "input")
  chat_openai_pattern <- r_patterns[[which(sapply(r_patterns, function(p) p$func == "chat_openai"))]]
  expect_true(grepl(chat_openai_pattern$regex, "response <- chat_openai(prompt)"))
})

test_that("Model save patterns match expected code snippets", {
  py_output <- get_detection_patterns("python", type = "output")

  # Test transformers save
  save_pattern <- py_output[[which(sapply(py_output, function(p) p$func == "model.save_pretrained"))]]
  expect_true(grepl(save_pattern$regex, "model.save_pretrained('./my_model')"))

  # Test torch save
  torch_pattern <- py_output[[which(sapply(py_output, function(p) p$func == "torch.save"))]]
  expect_true(grepl(torch_pattern$regex, "torch.save(model.state_dict(), 'model.pt')"))

  # Test MLflow
  mlflow_pattern <- py_output[[which(sapply(py_output, function(p) p$func == "mlflow.log_model"))]]
  expect_true(grepl(mlflow_pattern$regex, "mlflow.log_model(model, 'model')"))
})
