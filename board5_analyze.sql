
insert into `ml_dataset.board5_analyze_tmp` 
SELECT
  ml_generate_text_llm_result,
  CAST(JSON_EXTRACT_SCALAR(ml_generate_text_rai_result, '$.blocked') AS BOOL) AS is_safety_filter_blocked,
  * EXCEPT (ml_generate_text_llm_result,
    ml_generate_text_rai_result)
FROM
  ML.GENERATE_TEXT( MODEL `ml_dataset.lang_model_v1`,
    (
    SELECT
  	CONCAT(@request, post, @category  ) AS prompt,
      *
    FROM
      `ml_dataset.board5ch_ex` a where not exists (select * from `ml_dataset.board5_analyze_tmp` where titleid=a.titleid and post_id = a.post_id)
    LIMIT
      @mlimit),
    STRUCT( 0.1 AS temperature,
      50 AS max_output_tokens,    
      2 AS top_k,
      0.1 AS top_p, 
      TRUE AS flatten_json_output ));


