package com.blibli.oss.backend.example.client;

import com.blibli.oss.backend.example.client.model.BinResponse;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

@Service
public class BinListNativeWebClient {

  private WebClient webClient;

  @Value("${blibli.backend.apiclient.configs.binListApiClient.url}")
  private String url;

  public BinListNativeWebClient() {
    this.webClient = WebClient.builder()
        .baseUrl(url)
        .build();
  }

  public Mono<BinResponse> lookup(String number) {
    return webClient.get()
        .uri(url + "/" + number)
        .retrieve()
        .bodyToMono(BinResponse.class);
  }

}
