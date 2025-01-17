import 'package:forge2d/forge2d.dart';

class ParticleGroup {
  final ParticleSystem _system;
  final List<Particle> particles = [];
  int groupFlags = 0;
  double strength = 1.0;

  int _timestamp = -1;
  double _mass = 0.0;
  double _inertia = 0.0;
  final Vector2 _center = Vector2.zero();
  final Vector2 _linearVelocity = Vector2.zero();
  double _angularVelocity = 0.0;
  final Transform transform = Transform.zero()..setIdentity();

  bool destroyAutomatically = true;
  bool toBeDestroyed = false;
  bool toBeSplit = false;

  Object? userData;

  ParticleGroup(this._system);

  void add(Particle particle) {
    particles.add(particle);
  }

  bool contains(Particle particle) => particles.contains(particle);

  set mass(double mass) => _mass = mass;
  double get mass {
    updateStatistics();
    return _mass;
  }

  set inertia(double inertia) => _inertia = inertia;
  double get inertia {
    updateStatistics();
    return _inertia;
  }

  set center(Vector2 center) => _center.setFrom(center);
  Vector2 get center {
    updateStatistics();
    return _center;
  }

  Vector2 get linearVelocity {
    updateStatistics();
    return _linearVelocity;
  }

  double get angularVelocity {
    updateStatistics();
    return _angularVelocity;
  }

  Vector2 get position => transform.p;

  double get angle => transform.q.getAngle();

  void updateStatistics() {
    if (_timestamp != _system.timestamp) {
      final m = _system.particleMass;
      final _mass = m * particles.length;
      _center.setZero();
      _linearVelocity.setZero();
      for (final particle in particles) {
        _center.setFrom(_center + (particle.position * m));
        _linearVelocity.setFrom(_linearVelocity + (particle.velocity * m));
      }
      if (_mass > 0) {
        _center.x *= 1 / _mass;
        _center.y *= 1 / _mass;
        _linearVelocity.x *= 1 / _mass;
        _linearVelocity.y *= 1 / _mass;
      }
      _inertia = 0.0;
      _angularVelocity = 0.0;
      for (final particle in particles) {
        final position = particle.position;
        final velocity = particle.velocity;
        final px = position.x - _center.x;
        final py = position.y - _center.y;
        final vx = velocity.x - _linearVelocity.x;
        final vy = velocity.y - _linearVelocity.y;
        _inertia += m * (px * px + py * py);
        _angularVelocity += m * (px * vy - py * vx);
      }
      if (_inertia > 0) {
        _angularVelocity *= 1 / _inertia;
      }
      _timestamp = _system.timestamp;
    }
  }
}
