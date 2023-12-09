
MERGE `ml_dataset.board5_result` target USING `ml_dataset.board5_analyze_tmp`   tmp
ON(target.titleid = tmp.titleid AND target.post_id = tmp.post_id)
WHEN MATCHED THEN
  UPDATE SET ml_generate_text_llm_result = tmp.ml_generate_text_llm_result,  is_safety_filter_blocked = tmp.is_safety_filter_blocked
WHEN NOT MATCHED THEN
  INSERT ROW;
