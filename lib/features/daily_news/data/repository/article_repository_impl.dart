import 'dart:io';

import 'package:dio/dio.dart';
import 'package:news_app/core/constants/constants.dart';
import 'package:news_app/core/resources/data_state.dart';
import 'package:news_app/features/daily_news/data/data_sources/local/app_database.dart';
import 'package:news_app/features/daily_news/data/data_sources/remote/news_api_service.dart';
import 'package:news_app/features/daily_news/data/models/article.dart';
import 'package:news_app/features/daily_news/domain/entities/article.dart';
import 'package:news_app/features/daily_news/domain/repositories/article_repository.dart';

class ArticlerepositoryImpl implements ArticleRepository{
  final NewsApiService _newsApiService;
  final AppDatabase _appDatabase;
  ArticlerepositoryImpl(this._newsApiService,this._appDatabase);
  @override
  Future<DataState<List<ArticleModel>>> getNewsArticles() async {
    try{
      final httpResponse = await _newsApiService.getNewsArticles(
        apikey: newsAPIKey,
        country: countryQuery,
        category: categoryQuery,
      );

      if(httpResponse.response.statusCode == HttpStatus.ok) {
        print("Hey Error Got Avoided");
        return DataSuccess(httpResponse.data);
      }else{
        print("Hey Error got Occured");
        return DataFailed(
          DioException(
            error: httpResponse.response.statusMessage,
            response: httpResponse.response,
            type: DioExceptionType.badResponse,
            requestOptions: httpResponse.response.requestOptions
          )
        );
      }
    }
    on DioException catch(e){
      return DataFailed(e);
    }  
  }

  @override
  Future<List<ArticleModel>> getSavedArticles() {
   return _appDatabase.articleDAO.getArticles();
  }

  @override
  Future<void> removeArticle(ArticleEntity article) {
     return _appDatabase.articleDAO.deleteArticle(ArticleModel.fromEntity(article));
  }

  @override
  Future<void> saveArticle(ArticleEntity article) {
     return _appDatabase.articleDAO.inserArticle(ArticleModel.fromEntity(article));
  }

}