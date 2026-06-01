class AppRoutes {
  const AppRoutes._();

  static const login = '/login';
  static const home = '/';
  static const completeProfile = '/complete-profile';

  static const createTable = '/table/new';
  static const joinTable = '/table/join';

  static const joinByIdPattern = '/table/:id/join';
  static String joinById(String id) => '/table/$id/join';

  static const tableDetailPattern = '/table/:id';
  static String tableDetail(String id) => '/table/$id';

  static const livePattern = '/table/:id/live';
  static String live(String id) => '/table/$id/live';

  static const qrPattern = '/table/:id/qr';
  static String qr(String id) => '/table/$id/qr';

  static const cashoutPattern = '/table/:id/cashout';
  static String cashout(String id) => '/table/$id/cashout';

  static const closePattern = '/table/:id/close';
  static String closeTable(String id) => '/table/$id/close';

  static const checkPattern = '/table/:id/check';
  static String checkTable(String id) => '/table/$id/check';

  static const pixPattern = '/table/:id/pix';
  static String pix(String id) => '/table/$id/pix';

  static const addPlayerPattern = '/table/:id/add-player';
  static String addPlayer(String id) => '/table/$id/add-player';

  static const editBuyInsPattern = '/table/:id/participations/:pid/edit-buyins';
  static String editBuyIns(String tableId, String participationId) =>
      '/table/$tableId/participations/$participationId/edit-buyins';

  static const history = '/history';
}
