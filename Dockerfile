# PatchMon on Railway
# Official upstream image, pinned by version and digest. Bump both together
# (and add a CHANGELOG.md entry); a merge to main notifies every deployer.
FROM ghcr.io/patchmon/patchmon-server:2.1.8@sha256:bee093a3ad55925aad5efa9874c5075020b65c9adb8fa412958e211aac9cd094

# The start script runs as root only long enough to make the Railway volume
# (/data, root-owned when mounted) writable, then runs PatchMon as the image's
# own non-root user (nonroot, uid 65532).
USER 0:0
COPY --chmod=755 railway-start.sh /app/railway-start.sh

# Fixed defaults. Any of them can be overridden with a service variable.
ENV PORT=3000 \
    PATCHMON_SSH_KNOWN_HOSTS=/data/ssh/known_hosts \
    TZ=UTC

EXPOSE 3000
ENTRYPOINT ["/app/railway-start.sh"]
