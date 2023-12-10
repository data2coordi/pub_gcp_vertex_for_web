drop view  ml_dataset.board5_result_view;
create view ml_dataset.board5_result_view as 
SELECT 
  ifnull(
    replace(
      replace(
        REGEXP_EXTRACT(ml_generate_text_llm_result, r'分類:.*\n'),
      '**',''),
    '分類:',''),
  '解析失敗') AS category, 
  replace(REGEXP_EXTRACT(ml_generate_text_llm_result, r'分類理由:.*\n'),'**','') AS reason, 
  replace(REGEXP_EXTRACT(ml_generate_text_llm_result, r'要旨:.*'),'**','') AS summary, 
   post,
   post_date, 
   post_id, 
   title, 
   titleid, 
  ml_generate_text_llm_result 
from `ml_dataset.board5_result` 
where titleid!=-1 
