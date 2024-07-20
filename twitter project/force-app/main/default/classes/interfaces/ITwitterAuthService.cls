public interface ITwitterAuthService {
    void getAccessToken(String authcode);
    void getUserInfo(String accessToken, DateTime expirationDate);
}