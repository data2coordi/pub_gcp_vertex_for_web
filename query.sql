
select ml_generate_text_llm_result,post,prompt 
from `ml_dataset.board5_result` 
where titleid!=1 order by post_id limit 10;
