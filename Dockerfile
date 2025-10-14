FROM node:18-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./

# Check if package-lock.json exists, if not generate it
RUN if [ ! -f package-lock.json ]; then npm install; fi

# Now run npm ci for production
RUN npm ci --only=production

# Copy source code
COPY . .

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nextjs -u 1001

# Change ownership
RUN chown -R nextjs:nodejs /app
USER nextjs

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "const http = require('http'); const req = http.request('http://localhost:3000/health', {timeout: 3000}, (res) => { process.exit(res.statusCode === 200 ? 0 : 1); }); req.on('error', () => process.exit(1)); req.end();"

# Start application
CMD ["npm", "start"]