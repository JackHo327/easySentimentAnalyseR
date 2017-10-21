retre_entity_kind <- function(doc, kind){

      doc_cont <- doc$content      
      annotations <- NLP::annotations(doc)[[1]]
      if(hasArg(kind)){
            k <- sapply(annotations$features, '[[', "kind")
            doc_cont[annotations[k == kind]]
      }else{
            doc_cont[annotations[k == "entity"]]
      }

}

get_named_entity <- function(test_source, anno_list = c("person", "location", "organization")){
      
      merged_text_source_str <- str_replace_all(stringi::stri_enc_toutf8(paste0(test_source,collapse = " ")), "\\s+", " ") %>% as.String()
      sent_token <- Maxent_Sent_Token_Annotator()
      word_token <- Maxent_Word_Token_Annotator()
      pipline <- vector(mode = "list", length = length(anno_list)+2)
      pipline[[1]] <- sent_token
      pipline[[2]] <- word_token
      for(i in 3:(length(anno_list)+2)){
            pipline[[i]] <- openNLP::Maxent_Entity_Annotator(kind = anno_list[i-2])
      }
      text_anot <- NLP::annotate(s = merged_text_source_str, f = pipline)
      text_anot_plain <- NLP::AnnotatedPlainTextDocument(s = merged_text_source_str, annotations=text_anot)
      queue <- NULL
      list <- vector(mode = "list", length = length(anno_list))
      for(i in 1:length(anno_list)){
            queue <- retre_entity_kind(text_anot_plain,anno_list[i])
            queue <- data.frame(KeyWords = queue)
            queue$KeyWords <- queue$KeyWords %>% str_replace_all(pattern = "[^A-Za-z0-9_-|^\\s]",replacement = " ")
            list[[i]] <- queue
            names(list[[i]]) <- anno_list[i]
      }
      return(list)
}



cluster_word_hclust <- function(corpus, sparse = 0.9, method_dist = "euclidean", method_hclust = "average"){
      
      TermDocumentMatrix(x = corpus) %>% # generate term doc matrix
      removeSparseTerms(sparse=sparse) %>% # remove highly sparse terms
      scale() %>% # scale the matrix
      dist(method = method_dist) %>% # calculate the distances among terms based on "euclidean distance"
      hclust(method = method_hclust)
      
}


draw_dendrogram <- function(hclust, num_cluster = 4, main_title = "Word Clusters", border_type = 8, border_lin_type = 5, border_line_width = 2){
      
      hclust %>% as.dendrogram() %>% dendextend::set("branches_k_color", k = num_cluster) %>% plot(main = main_title, col.main = "salmon") 
      hclust %>% as.dendrogram() %>% dendextend::set("branches_k_color", k = num_cluster)  %>% rect.dendrogram(k = num_cluster, border = border_type,  lty = border_lin_type, lwd = border_line_width)
      
}

calclulate_score <- function( sentences, pos, neg){
      
      pos.score <- sapply(sentences, function(x){
            tm_term_score(x,pos)
      }) %>% as.numeric()
      
      neg.score <- sapply(sentences, function(x){
            tm_term_score(x,neg)
      }) %>% as.numeric()
      
      dt <- data.table(pos.score,neg.score)
      
      return(dt)
}