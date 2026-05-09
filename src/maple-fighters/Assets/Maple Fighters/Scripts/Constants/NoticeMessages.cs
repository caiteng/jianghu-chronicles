namespace Scripts.Constants
{
    public static class NoticeMessages
    {
        public static class AuthView
        {
            public const string EmptyEmailAddress = "邮箱地址不能为空。";
            public const string InvalidEmailAddress = "邮箱地址格式不正确。";
            public const string EmptyPassword = "密码不能为空。";
            public const string ShortPassword = "请输入更长的密码。";
            public const string EmptyConfirmPassword = "确认密码不能为空。";
            public const string PasswordsDoNotMatch = "两次输入的密码不一致。";
            public const string EmptyFirstName = "名字不能为空。";
            public const string EmptyLastName = "姓氏不能为空。";
            public const string ShortFirstName = "名字太短。";
            public const string ShortLastName = "姓氏太短。";
            public const string WrongPassword = "密码不正确。";
            public const string WrongEmailAddress = "该邮箱地址不存在。";
            public const string RegistrationSucceed = "注册成功！";
            public const string UnknownError = "发生未知错误，请重试。";
        }

        public static class GameServer
        {
            public const string ConnectionClosed = "与游戏服务器的连接已断开，请重试。";
        }

        public static class GameServerBrowserView
        {
            public const string UnknownError = "发生未知错误，请重试。";
        }

        public static class CharacterView
        {
            public const string CreationFailed = "角色创建失败，请重试。";
            public const string DeletionFailed = "角色删除失败，请重试。";
            public const string NotFound = "未找到角色，请创建新角色。";
            public const string NameAlreadyInUse = "角色名已被占用。";
            public const string UnknownError = "发生未知错误，请重试。";
        }
    }
}
