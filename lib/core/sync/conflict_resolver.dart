/// Determines which version of a record wins when the same row exists
/// both locally (Drift) and remotely (Firestore).
///
/// Strategy: **last-write-wins** using the `updatedAt` timestamp.
///
/// A local record is considered "dirty" when `isSynced == false` — i.e. it
/// has been modified after the last successful push.  A dirty local record
/// always wins over a remote record with the same or earlier timestamp,
/// because it represents work the user did while offline that has not yet
/// reached the server.
///
/// If the local record is clean (already synced) and the remote timestamp is
/// strictly newer, the remote version wins and should overwrite the local row.
class ConflictResolver {
  const ConflictResolver._();

  /// Returns true when the remote record should overwrite the local one.
  ///
  /// [localUpdatedAt]  — the `updatedAt` value from the local Drift row.
  /// [remoteUpdatedAt] — the `updatedAt` value decoded from the Firestore doc.
  /// [localIsSynced]   — the `isSynced` flag on the local row.
  static bool remoteWins({
    required DateTime localUpdatedAt,
    required DateTime remoteUpdatedAt,
    required bool localIsSynced,
  }) {
    // A dirty local record (unsent changes) always beats the remote version.
    if (!localIsSynced) return false;

    // Clean local: accept the remote update only when it is strictly newer.
    return remoteUpdatedAt.isAfter(localUpdatedAt);
  }
}
